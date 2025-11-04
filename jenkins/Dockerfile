FROM jenkins/jenkins:lts

USER root

# Install Docker CLI to allow Jenkins to launch Packer containers
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

USER jenkins

# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins \
    docker-workflow:563.vd5d2e5c4007f \
    pipeline-stage-view:2.34 \
    credentials-binding:523.vd859a_4b_122e6 \
    git:5.2.0
```

### jenkins/docker-compose.yml
```yaml
version: '3.8'

services:
  jenkins:
    build: .
    container_name: jenkins-master
    privileged: true
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
    restart: unless-stopped

volumes:
  jenkins_home:
    driver: local
