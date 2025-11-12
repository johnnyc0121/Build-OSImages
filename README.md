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

#### Set up Azure subscription
- Create a resource group to use when buliding the images using Packer
- Create a resource group to store the images once they are created
- Create a virtual network / subnet to use for the infrastructure and the VMs created when building the images
- Create a network security group (NSG) to limit the traffic going into the virtual network / subnet
    - Recommend creating an inbound NSG rule to restrict inbound access to only your external IP address (there are numerous ways to determine your external IP)

#### Prepare Windows VM
- Create an Windows VM in Azure subscription
- Give it a public IP so that it's accessible (or use a bastion host)
- Install SSH client tool so that the Ubuntu VM can be accessed

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
