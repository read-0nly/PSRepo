install-module azuread
$Workfolder = ([system.environment]::getfolderpath("Desktop")+"\AppControl")
$IntuneSamplets = $Workfolder + "\IntuneSamples"

if(-not(test-path $Workfolder)){
mkdir $Workfolder
}
if(-not(test-path $IntuneSamplets)){
mkdir $IntuneSamplets
}

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
