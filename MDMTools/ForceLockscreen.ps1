
New-ItemProperty -Path "hkcu:\Control Panel\Desktop" -Name "SCRNSAVE.EXE" -value "C:\Windows\System32\scrnsave.scr" –Force
New-ItemProperty -Path "hkcu:\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -value 1 –Force
New-ItemProperty -Path "hkcu:\Control Panel\Desktop" -Name "ScreenSaveActive" -value 1 –Force
New-ItemProperty -Path "hkcu:\Control Panel\Desktop" -Name "ScreenSaveTimeOut" -value 900 –Force

# reg add hkcu\Software\Microsoft\Windows\CurrentVersion\Policies\System /v NoDispScrSavPage /t REG_dword /d 4 #Blocks the panel


#Force ScreenSaverIsSecure without needing the reboot
try {
	Add-Type @"
		using System;
		using System.Runtime.InteropServices;
		using Microsoft.Win32;
		namespace SecureSaver
		{
			public class secureScreensaver
			{
				[DllImport( "user32.dll", SetLastError = true, CharSet = CharSet.Auto )]
				private static extern int SystemParametersInfo ( int uAction, int uParam, string lpvParam, int fuWinIni );
				public static void Set ()
				{
					SystemParametersInfo( 0x77, 1,"", 0x1 | 0x2 );
				}
			}
		}
"@
} catch {}

[SecureSaver.secureScreensaver]::Set()
rundll32.exe user32.dll, UpdatePerUserSystemParameters > $null
rundll32.exe user32.dll, UpdatePerUserSystemParameters > $null