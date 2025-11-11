### packer/scripts/configure-os.ps1

# Configure Windows Server OS settings
Write-Host "Configuring OS settings..."

# Set timezone
Set-TimeZone -Id "Eastern Standard Time"

# Configure power settings for high performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable IPv6
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Value 0xff -PropertyType DWord -Force

# Configure Windows Update settings
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0 -Force

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Configure page file
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
$computersys.AutomaticManagedPagefile = $false
$computersys.Put()
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name='C:\\pagefile.sys'"
$pagefile.InitialSize = 4096
$pagefile.MaximumSize = 8192
$pagefile.Put()

# Disable Windows Defender real-time monitoring (customize based on requirements)
# Set-MpPreference -DisableRealtimeMonitoring $true

Write-Host "OS configuration completed successfully"
