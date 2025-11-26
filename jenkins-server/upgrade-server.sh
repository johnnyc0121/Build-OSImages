#!/bin/bash

# Generate datestamp in YYYYMMDD format
DATESTAMP="20251110"
#DATESTAMP=$(date +%Y%m%d)

# Define image name
IMAGE_NAME="jenkins-server"

docker run -d \
  --name jenkins-server \
  --user 2000:2000 \
  --network jenkins-network \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  --restart unless-stopped \
  jenkins-server:${DATESTAMP}
