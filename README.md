# Shipyard
Quickly generate and destroy docker hosts for malware testing


## Usage

Install Docker
`./shipyard install`

Run a new container for testing
`./shipyard run ubuntu`

Run a new container with a special IP address
`./shipyard run ubuntu 10.2.4.6`

Running creates a copy of the current directory within the docker container and gives you a bash shell into the machine.
