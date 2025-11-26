# Build-OSImages
Code to build Custom Windows Server Images in Azure
*** Still In Development ***

## Requirements
- Azure subscription
- Ubuntu servers for Jenkins server/agent installs (24.04 Ideal)
- Windows Server OS knowledge (for building OS images)
- OPTIONAL: Windows Server (to connect to Ubuntu and to also view the Jenkins UI)

### Infrastructure Setup

#### Set up Azure subscription
- Terraform code available to set up all resources, see the infra subfolder
- Create a resource group to store the resources for the VMs noted below
- Create a resource group to use when buliding the images using Packer
- Create a resource group to store the images once they are created
- Create a virtual network / subnet to use for the infrastructure and the VMs created when building the images (/24 is sufficient)
- Create a network security group (NSG) to limit the traffic going into the virtual network / subnet
    - Recommend creating an inbound NSG rule to restrict inbound access to the jump server to only your external IP address (there are numerous ways to determine your external IP)

#### OPTIONAL: Prepare Windows (Jump Server)
- Terraform code is commented out but can be used if desired
- Create an Windows VM in Azure subscription
- Give it a public IP so that it's accessible (or use a bastion host)
- Install SSH client tool so that the Ubuntu VM can be accessed

#### Prepare Ubuntu VMs
- Create public IP address for the Jenkins server VM so that it's accessible from your public IP
- Create Ubuntu VMs in Azure subscription, for both Jenkins server and agents
- Make note of the public/private IPs used for accessibility later
- Execute below commands to update system and set up Docker

```
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker on Jenkins server/agent VMs
More information: https://docs.docker.com/engine/install/ubuntu/

# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
 
# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Refresh apt and install Docker
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io
```
#### Install/Configure Jenkins
- jenkins-server subfolder contains config for configuring Jenkins
