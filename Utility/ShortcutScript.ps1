#This will effectively be a menu that calls scripts straight from github with iex (iwr ).content
# iex (iwr "https://bit.ly/36tdMTj").content
#Meant to simplify calling these things in general - run iex(iwr THISSCRIPT).content then run through the menu and it calls the rest

write-host "1: EVTX Ripper"
write-host "2: InterTransmission"
write-host "2: CompareForDupes"
write-host "4: BatchJPG"
write-host "5: AutopilotAssigner"
write-host "6: AutoAutopilot"
write-host "7: AgentLaunch"
write-host "8: MightyHonk"
write-host "9: MeteorGame"
$Selected = ""
$MenuLoop = $true
while($global:MenuLoop){
  switch((read-host "Please pick a script to run")){  
    '1' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/EVTXRipper.ps1").content; $global:MenuLoop = $false}
    '2' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/InterTransmission.ps1").content; $global:MenuLoop = $false}
    '3' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/CompareForDupes.ps1").content; $global:MenuLoop = $false}
    '4' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/BatchJPG.ps1").content; $global:MenuLoop = $false}
    '5' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/AutopilotAssigner.ps1").content; $global:MenuLoop = $false}
    '6' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/AutoAutopilot.ps1").content; $global:MenuLoop = $false}
    '7' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/AgentLaunch.ps1").content; $global:MenuLoop = $false}
    '8' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Fun/MightyHonk.ps1").content; $global:MenuLoop = $false}
    '9' {$Selected = (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Fun/MeteorGame.ps1").content; $global:MenuLoop = $false}
  }
}
iex $selected
