#Intune's kiosk mode has a nice "Autologon" feature, but this creates a local account, and MSfB apps need an AAD acct to license.
#Instead, you can target AAD users for kiosk then deploy this alongside the kiosk profile to configure autologon for that kiosk AAD user

$KeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 	#This should be left as-is
$DefaultUserName = "user@domain.com" 										                  #Set this to the user's UPN ie. user@tenant.onmicrosoft.com
$DefaultPassword = "P@ssw0rd!" 											                     	#Set this to the user's password

#Make sure any previous configuration is flushed and AutoLogonSID is deleted
	Remove-ItemProperty -Path $KeyPath -Name "AutoAdminLogon"
	Remove-ItemProperty -Path $KeyPath -Name "AutoLogonSID"
	Remove-ItemProperty -Path $KeyPath -Name "DefaultDomainName"
	Remove-ItemProperty -Path $KeyPath -Name "DefaultPassword"
	Remove-ItemProperty -Path $KeyPath -Name "DefaultUserName"

#Configure new autologon
	New-ItemProperty -Path $KeyPath -Name "AutoAdminLogon" -Value 1  -PropertyType "DWord"
	New-ItemProperty -Path $KeyPath -Name "DefaultPassword" -Value $DefaultPassword  -PropertyType "String"
	New-ItemProperty -Path $KeyPath -Name "DefaultUserName" -Value $DefaultUserName  -PropertyType "String"
	New-ItemProperty -Path $KeyPath -Name "DefaultDomainName" -Value "AzureAD"  -PropertyType "String"
