#!/bin/bash

# Generate datestamp in YYYYMMDD format
DATESTAMP=$(date +%Y%m%d)

# Define image name
IMAGE_NAME="jenkins-agent"

# Build the image with the datestamp tag
docker build -f Dockerfile -t ${IMAGE_NAME}:${DATESTAMP} .
