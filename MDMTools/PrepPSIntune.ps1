install-module azuread
$Workfolder = ($env.USERPROFILE)
$IntuneSamplets = $Workfolder + "\IntuneSamples"

if(-not(test-path $Workfolder)){
mkdir $Workfolder
}
if(-not(test-path $IntuneSamplets)){
mkdir $IntuneSamplets
}
Start-BitsTransfer -Source "https://github.com/microsoftgraph/powershell-intune-samples/archive/master.zip" -Destination ($IntuneSamplets+"\master.zip")
expand-archive ($IntuneSamplets+"\master.zip") $IntuneSamplets -force
