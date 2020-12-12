#make a powershell shortcut to it, drop vhd file on the shortcut. it either attaches or detaches (mounts/unmounts) the vhd file 
#depending on the current state. So drop to mount, and once you're done, drop again to unmount.
#Example Shortcut: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file "c:\VHD\mounter.ps1"
#Windows 7 compatible since it doesn't use the mount cmdlets

Param
(
    [Parameter(Position=0)]
    $dropFile = (read-host "Enter path to vhd file").replace("`"","")
)
$detail = 'sel vdisk file="'+$dropfile+'"
detail vdisk'

$attach = 'sel vdisk file="'+$dropfile+'"
attach vdisk'

$detach = 'sel vdisk file="'+$dropfile+'"
detach vdisk'

$vhdDetails = [Int32](((echo $detail) | diskpart) -match "Associated.+").replace("Associated disk#: ", "")
if ($vhdDetails -eq $null)
{
    (echo $attach) | diskpart
}
else{
    (echo $detach) | diskpart
}
$vhdDetails = $null
