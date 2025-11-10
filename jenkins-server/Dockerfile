FROM jenkins/jenkins:2.528.1-lts-jdk21

USER root

# Copy self-signed certificate into the image
COPY certs/jenkins.crt /tmp/jenkins.crt

# Import the certificate into the Java cacerts keystore
# -keystore: Specifies the path to the cacerts file
# -storepass: The default password for cacerts is 'changeit'
# -alias: A unique alias for your certificate
# -file: The path to your certificate file within the container
RUN keytool -import -trustcacerts -noprompt \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit \
    -alias your_certificate_alias \
    -file /tmp/jenkins.crt

# Clean up the copied certificate file (optional, but good practice)
RUN rm /tmp/jenkins.crt

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

# Update Jenkins user ID
RUN usermod --uid 2000 jenkins && \
    groupmod --gid 2000 jenkins && \
    chown -R jenkins:jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

# Switch back to Jenkins user
USER jenkins

# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins \
    docker-plugin \
    docker-workflow \
    pipeline-stage-view \
    credentials-binding \
    windows-cloud \
    blueocean \
    ws-cleanup \
    git
