FROM jenkins/inbound-agent:latest

USER root

# Install Docker CLI (for Docker-in-Docker capabilities)
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install additional tools
RUN apt-get update && \
    apt-get install -y \
    git \
    wget \
    unzip \
    python3 \
    python3-pip \
    jq && \
    sshpass && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Ansible
RUN pip3 install --no-cache-dir ansible ansible-core

# Install Packer (optional - if agent will run Packer directly)
RUN PACKER_VERSION=1.14.2 && \
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip

# Add jenkins user to docker group (will use host docker socket)
RUN groupadd -g 999 docker || true && \
    usermod -aG docker jenkins

USER jenkins

WORKDIR /home/jenkins
