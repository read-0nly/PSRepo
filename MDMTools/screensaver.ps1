
New-Item -Path "hklm:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Name "SCRNSAVE.EXE" -value "C:\Windows\System32\scrnsave.scr" –Force
New-Item -Path "hklm:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -value 1 –Force
New-Item -Path "hklm:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Name "ScreenSaveActive" -value 1 –Force
New-Item -Path "hklm:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Name "ScreenSaveTimeOut" -value 900 –Force