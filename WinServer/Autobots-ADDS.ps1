#First script in a group of scripts to streamline the rolling out of ADDS for testing
#Run in Windows Server

param(
	$credentials = get-credentials
	$domainName = read-host "Please enter the domain name (example.com)"
	$domainNet = read-host "Please enter the domain NETBIOS name (EXAMPLE)"
)
install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment	
get-netIPconfiguration |%{
	set-dnsclientserveraddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses ($_.ipv4address, "8.8.8.8")
	New-NetIPAddress –IPAddress $_.ipv4address -DefaultGateway $_.ipv4defaultgateway -PrefixLength 24 -InterfaceIndex $_.InterfaceIndex
}
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -DomainMode “Win2012R2” -DomainName $domainName -DomainNetbiosName $domainNet -ForestMode “Win2012R2” -InstallDns:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$true -SysvolPath “C:\Windows\SYSVOL” -Force:$true
