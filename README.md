# Build-OSImages
Code to build Custom Windows Server Images in Azure
*** Still In Development ***

## Requirements
- Azure subscription
- Ubuntu server for Jenkins server/agent installs
- Windows Server OS knowledge (for building OS images)
- Ubuntu Server (24.04 ideal)
- Windows Server (to connect to Ubuntu and to also view the Jenkins UI)

### Infrastructure Setup

#### Prepare Ubuntu VM
- Create an Ubuntu VM in Azure subscription
- Execute below commands to update system and set up Docker

```
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
