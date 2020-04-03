# This will go through all the Win32 apps listed in Intune
# Pull the path from the detection method
# and create file path rules for each of them then convert to bin
# This is intended to generate an exclusion file for app control
# path-based rules are naturally insecure since there's no real integrity check. This may still be enough for your uses.
install-module azuread
$Workfolder = ([system.environment]::getfolderpath("Desktop")+"\AppControl")
$xmlPath = ($WorkFolder+"\Output.xml")
$binPath = ($WorkFolder+"\Output.bin")

$Tenant = (iex (iwr "https://raw.githubusercontent.com/microsoftgraph/powershell-intune-samples/master/CompanyPortalBranding/CompanyPortal_Get.ps1" -usebasicparsing).content)

write-host "Connected to : " -ForegroundColor Green -NoNewline
write-host ($Tenant.displayName) -ForegroundColor Magenta


$uri = "https://graph.microsoft.com/beta/deviceappmanagement/mobileapps?select=id,displayname"
$allApps = (Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value
$win32apps = @()

$allapps | where-object {$_.'@odata.type' -like "*win32*"} | %{
    $uri = ("https://graph.microsoft.com/beta/deviceappmanagement/mobileapps/"+$_.id)
    $win32apps +=@((Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get))
}
$PathTable = $win32Apps | select displayname,detectionrules | %{[pscustomobject]@{"Name"=$_.displayname;"Path"=($_.detectionRules.path + $_.detectionRules.fileorfoldername)}}

$PathTable | %{
    $_.Path

$Rule = New-CIPolicyRule -FilePathRule $_.path
if(test-path $xmlPath){
    Merge-CIPolicy -outputfile $xmlPath -PolicyPaths $xmlPath -Rules $Rule
}
else{
    New-CIPolicy -FilePath $xmlPath -Rules $Rule
}
    
}
Set-CIPolicyIdInfo -FilePath $xmlPath -reset
ConvertFrom-CIPolicy -XmlFilePath $xmlPath -BinaryFilePath $binPath
#$xmlPath
#$binPath
