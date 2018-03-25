#!/bin/bash

# Create the sample bashrc file
read -d '' BASHRC <<"EOF"
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\\[\\033[01;31m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '
else
    PS1='\\u@\\h:\\$ '
fi
case "$TERM" in
xterm*|rxvt*)
    PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"
    ;;
*)
    ;;
esac
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi
EOF

install() {
    # Install docker if required
    command -v docker &>/dev/null;
    [ "$?" = "0" ] && echo "Docker is already installed" && return
    
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo 'deb https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install docker-ce
    systemctl start docker
    docker run hello-world
}

setnetwork() {
    # Create a network for the docker images to use
    [ "$1" = "" ] && echo "USAGE: $0 setnetwork <ip-address>" && return
    # Check if the network exists, if so, delete it
    if [ "`docker network ls | grep 'shipyard-net'`" != "" ]; then
        docker network rm shipyard-net &>/dev/null;
    fi
    echo "Creating docker shipyard-net $1/8"
    res=`docker network create --subnet=$1/8 shipyard-net`
    # Print the error if one is generated
    [ "$?" != "0" ] && echo -e "ERROR CREATING NETWORK:\n $res" && exit
}

run() {
    # Run a docker image
    # Mount the current directory to the docker image in /root
    [ "$1" = "" ] && echo "USAGE: $0 run <docker-image> [ip-address]" && return
    # Check if we are using a specific network
    if [ "$2" != "" ]; then
        # Check if the network doesnt exists
        if [ "`docker network ls | grep 'shipyard-net'`" = "" ]; then
            # Add the network if it doesnt exist
            setnetwork $2
            # Mark the network for deletion later
            DEL_NET="TRUE"
        fi
        IP="--net shipyard-net --ip $2"
    fi
    echo -e "Executing:\n\tdocker run -it $IP --rm -v `pwd`:/root $1 bash
Continue? [Y/n]"
    read inst
    [ "$inst" = "n" ] && return
    
    # By default docker -v reflects changes made in the container onto the host
    # We dont want this so we copy everything to a tmp directory
    rm -fr /tmp/shipyard &>/dev/null
    mkdir /tmp/shipyard &>/dev/null
    cp -r . /tmp/shipyard/ &>/dev/null
    echo "$BASHRC" > /tmp/shipyard/.bashrc
    docker run -it $IP --rm -v /tmp/shipyard:/root $1 bash
    
    # Delete the shipyard net if we just created it
    if [ "$DEL_NET" != "" ]; then
        docker network rm shipyard-net &>/dev/null;
        echo "[*] Deleted the Shipyard network"
    fi
}

USAGE() {
    echo -e "USAGE: $0 <command>"
    echo -e "\nCommands:"
    echo -e "\trun <image> [ip]\n\tsetnetwork <ip>\n\tinstall"
}

# Check if docker is installed, prompt for install if not
command -v docker &>/dev/null;
if [ "$?" != "0" ] && [ "$COM" != "install" ]; then
    echo -n 'Docker is not installed. Would you like to install? [y/N]'
    read inst
    if [ "$inst" = "y" ]; then
	install
    fi
    exit
fi

# Parse the args
flag=`getopt -u -o i:a:n:h: -l image:,address:,help: -n Shipyard -- "$@"` ;
if [ "$?" != "0" ]; then
    USAGE
    exit;
fi
# Set the positional arguments to the output of flag
set -- $flag
# Default args
IMAGE="shipyard"
# Loop through the args and set values accordingly
while true; do
    case "$1" in
	-n | --add-network )
	    setnetwork $2; exit ;;
	-i | --image )
	    IMAGE=$2; shift 2 ;;
	-a | --address )
	    IP=$2; shift 2 ;;
	-h | --help )
	    USAGE; exit ;;
	-- )
	    shift; break ;;
	* )
	    break ;;
    esac;
done;

run $IMAGE $IP
