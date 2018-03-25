# Shipyard
Quickly generate and destroy docker hosts for malware testing


## Usage

Run a new container for testing
`./shipyard -i ubuntu:xenial`

Run a new container with a special IP address
`./shipyard -i ubuntu -a 10.2.4.6`

Running creates a copy of the current directory within the docker container and gives you a bash shell into the machine.
