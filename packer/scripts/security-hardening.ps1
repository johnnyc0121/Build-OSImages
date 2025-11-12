# Apply security hardening configurations
Write-Host "Applying security hardening..."

# Disable unnecessary services, or for security reasons
$servicesToDisable = @(
    "RemoteRegistry",
    "SSDPSRV",
    "upnphost",
    "WMPNetworkSvc",
    "Spooler"
)

foreach ($service in $servicesToDisable) {
    Write-Host "Disabling service: $service"
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
}

# Configure Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Disable SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# Enable Windows Defender exploit protection
Set-ProcessMitigation -System -Enable DEP,SEHOP,ForceRelocateImages

# Configure audit policies
auditpol /set /category:"Account Logon" /success:enable /failure:enable
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
auditpol /set /category:"Object Access" /success:enable /failure:enable
auditpol /set /category:"Policy Change" /success:enable /failure:enable
auditpol /set /category:"Privilege Use" /success:enable /failure:enable
auditpol /set /category:"System" /success:enable /failure:enable

# Set password policy
net accounts /minpwlen:14 /maxpwage:60 /minpwage:1 /uniquepw:24

# Configure TLS settings - disable old protocols
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'Enabled' -Value 0 -PropertyType 'DWord' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWord' -Force

New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'Enabled' -Value 0 -PropertyType 'DWord' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWord' -Force

# Enable Windows Defender features
Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue
Set-MpPreference -PUAProtection Enabled -ErrorAction SilentlyContinue

# Disable anonymous access
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 1 -PropertyType DWord -Force

Write-Host "Security hardening completed successfully"
