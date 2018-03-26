# Shipyard
Quickly generate and destroy docker hosts for malware testing

## Installation and Setup
If docker is not installed, shipyard will install it
```
./shipyard.sh
```
> Installation has only been testing on debian/kali linux


Make sure the docker service is running
`service docker start`

Build the default shipyard docker image
`docker build -t shipyard default`

Allow shipyard to run from anywhere
```
ln -s `pwd`/shipyard.sh /bin/shipyard
```

Shipyard is now fully setup and ready for use.

## Usage
Run a new container for testing
`shipyard -i ubuntu:xenial`

Run a new container with a special IP address
`shipyard -i ubuntu -a 10.2.4.6`

Running creates a copy of the current directory within the docker container and gives you a bash shell into the machine.
