#This will effectively be a menu that calls scripts straight from github with iex (iwr ).content
#Meant to simplify calling these things in general - run iex(iwr THISSCRIPT).content then run through the menu and it calls the rest

write-host "1 : EVTX Ripper"
if((read-host "Please pick a script to run")-eq '1'){
  iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/EVTXRipper.ps1").content
}
