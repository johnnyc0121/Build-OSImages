#!/bin/bash

# Generate datestamp in YYYYMMDD format
DATESTAMP=$(date +%Y%m%d)

# Define image name
IMAGE_NAME="jenkins-server"

docker run -d \
  --name jenkins-server-${DATESTAMP} \
  --privileged \
  --user root \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --network jenkins-network \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  -e DOCKER_HOST="unix:///var/run/docker.sock" \
  --restart unless-stopped \
  jenkins-server:${DATESTAMP}
