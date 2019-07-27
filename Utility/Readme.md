# Utility #

### BatchJPG ##
Changes all the file extensions in a folder to .jpg

### Compare for Dupes ##
Goes through 2 folders and compares all files, first for name match, then for hash match, and tries to automate clearing out the dupes as much as possible. Defers to user when it's not obvious how to proceed.

### Del Onenote Printer ##
Onenote 2016 keeps adding the printer back - if you're adamant not to have it you can add this as a service to run when idle or on logon. It'll delete it every time it runs, if it exists. Might need to remove any echos/write-hosts.

### Generic Script Tools ##
Things that are good to have in most scripts. Right now just a quick way to configure powershell to meet module and script requirements before continuing. Gonna have some pre-generated winforms too to make GUI easier to implement, just gotta build the things.

EDIT: Otherwise, use Requires - it's much easier: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires?view=powershell-6

### LogCollector ##
Set the current scenario to the scenario in question, then send as-is to be run on affected device - collects relevant logs for scenario, all in folder on desktop. Easier that asking them to export the logs themselves.

EDIT: Or just use MdmDiagnosticsTool.exe and define custom "areas" in the registry and it's maybe cleaner for you, especially if it's a scenario you expect to collect logs from a device for often. I have to stop finding things that make my things obsolete lol

### Mounter ###
Make a powershell shortcut to it, drop vhd file on the shortcut. it either attaches or detaches (mounts/unmounts) the vhd file depending on the current state. So drop to mount, and once you're done, drop again to unmount.

Example Shortcut: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file "c:\VHD\mounter.ps1"
#### Windows 7 compatible since it doesn't use the mount cmdlets ####

### InterTransmission ##
Transmits text (or a text file) to a window using SendKeys

### Set AAD AutoLogon ##    
Intune's kiosk mode has a nice "Autologon" feature, but this creates a local account, and MSfB apps need an AAD acct to license.
Instead, you can target AAD users for kiosk then deploy this alongside the kiosk profile to configure autologon for that kiosk AAD user

I really wanted this to work but it doesn't quite work as hoped. Licensing is hard guys.

### Set Wallpaper ##
Maybe this should be under MDMTools, sets the wallpaper of the current user. Gets around the Enterprise requirement of "Set desktop background" in Intune
