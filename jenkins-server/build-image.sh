#!/bin/bash

# Generate datestamp in YYYYMMDD format
DATESTAMP=$(date +%Y%m%d)

# Define image name
IMAGE_NAME="jenkins-server"

# Generate the self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/jenkins.key -out certs/jenkins.crt -subj "/CN=jenkins-server"

# Build the image with the datestamp tag
docker build -f Dockerfile -t ${IMAGE_NAME}:${DATESTAMP} .
