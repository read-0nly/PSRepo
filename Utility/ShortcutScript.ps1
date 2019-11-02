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
switch((read-host "Please pick a script to run")){
  '1' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/EVTXRipper.ps1").content}
  '2' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/InterTransmission.ps1").content}
  '3' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/CompareForDupes.ps1").content}
  '4' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/BatchJPG.ps1").content}
  '5' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/AutopilotAssigner.ps1").content}
  '6' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/AutoAutopilot.ps1").content}
  '7' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/AgentLaunch.ps1").content}
  '8' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Fun/MightyHonk.ps1").content}
  '9' {iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Fun/MeteorGame.ps1").content}
  
}
