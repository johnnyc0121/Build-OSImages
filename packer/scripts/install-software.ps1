# Install common software packages
Write-Host "Starting software installation..."

# Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install software via Chocolatey
choco install -y googlechrome
choco install -y 7zip
choco install -y notepadplusplus
choco install -y git

# Install .NET Framework 4.8
choco install -y dotnetfx

# Install Visual C++ Redistributables
choco install -y vcredist-all

# Install Azure CLI
choco install -y azure-cli

Write-Host "Software installation completed successfully"
