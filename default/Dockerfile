FROM ubuntu:xenial
# Copy the package list into the container
ADD Packages.txt /pkg.txt
# Update the repo data
RUN apt-get update
# Install all the packages in the file
RUN xargs -a /pkg.txt -- apt-get install -y
# Start the image in /root
WORKDIR /root
