**Convert Base64 blob to UTF 8 (Stop using suspicious online decoders!)**

```powershell
[System.Text.Encoding]::UTF8.getString([convert]::FromBase64String((read-host "Enter base64 blob")))
```

**Fetch the enrolling user of an enrolled device without talking to AAD/Intune or being in that user's session**
```powershell
(get-itemproperty "hklm:\SOFTWARE\Microsoft\Enrollments\*" | where-object {$_.upn -ne $null}).upn
```

**Happy Friday**

```powershell
$global:ascii = "╬░♥╔╗─╔╦═══╦═══╦═══╦╗──╔╗♥░─╬`n╬░♥║║─║║╔═╗║╔═╗║╔═╗║╚╗╔╝║♥░─╬`n╬░♥║╚═╝║║─║║╚═╝║╚═╝╠╗╚╝╔╝♥░─╬`n╬░♥║╔═╗║╚═╝║╔══╣╔══╝╚╗╔╝─♥░─╬`n╬░♥║║─║║╔═╗║║──║║────║║──♥░─╬`n╬░♥╚╝─╚╩╝─╚╩╝──╚╝────╚╝──♥░─╬`n╬░♥╔═══╗───╔═╗─╔═╗───────♥░─╬`n╬░♥║░══╬═╦═╬═╬═╝░╠═══╦═╦═╗░─╬`n╬░♥║░╔═╣░╔═╣░║╔╗░║╔╗░╠══░║░─╬`n╬░♥╚═╝░╚═╝░╚═╩═══╩═╩═╩═══╝░─╬"
$red = [char]27 + "[91m"
$yellow = [char]27 + "[93m"
$blue = [char]27 + "[94m"
$green = [char]27 + "[92m"
$reset = [char]27 + "[0m"
$yellows = @("╔","╦","╗","╚","═","╝","║","╠","╣","╩","╬")
$reds = @("♥")
$blues = @("─")
$greens = @("░")
$animationDelay = 1
function draw {
  cls
  $yellows | %{$global:ascii = $global:ascii.replace($_,($yellow+$_))}
  $reds | %{$global:ascii = $global:ascii.replace($_,($red+$_))}
  $blues | %{$global:ascii = $global:ascii.replace($_,($blue+$_))}
  $global:ascii += $reset
  $global:ascii | out-host
  start-sleep $animationDelay
  cls
  $yellows | %{$global:ascii = $global:ascii.replace($_,($green+$_))}
  $reds | %{$global:ascii = $global:ascii.replace($_,($red+$_))}
  $blues | %{$global:ascii = $global:ascii.replace($_,($blue+$_))}
  $global:ascii += $reset
  $global:ascii | out-host
  start-sleep $animationDelay
}
while ($true){
  draw
}
```
