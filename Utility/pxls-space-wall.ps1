#Set the style and image URL
[string]$style = "Fit"
[string]$url = "https://pxlsfiddle.com/boarddata.png"

#Hashtable of values for setting wallpaper styles
$WallpaperStyleValues = @{
	"Fill" = @(10,0);
	"Fit" = @(6,0);
	"Stretch" = @(2,0);
	"Span" = @(22,0);
	"Tile" = @(0,1);
	"Center" = @(0,0)
}
#set the new wallpaper, pipe the confirmation to null because any console interaction will cause the script to fail running as a deployed script
#Set the wallpaper style details
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d $WallpaperStyleValues[$style][0] /f > $null
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d $WallpaperStyleValues[$style][1] /f > $null
#Create minimalist User32 interface class
try {
	Add-Type @"
		using System;
		using System.Runtime.InteropServices;
		using Microsoft.Win32;
		namespace Wallpaper
		{
			public class Setter
			{
				[DllImport( "user32.dll", SetLastError = true, CharSet = CharSet.Auto )]
				private static extern int SystemParametersInfo ( int uAction, int uParam, string lpvParam, int fuWinIni );
				public static void SetWallpaper ( string path )
				{
					SystemParametersInfo( 20, 0, path, 0x1 | 0x2 );
				}
			}
		}
"@
} catch {}

while($true){
#Generate local file path for image
if(test-path ([system.environment]::GetEnvironmentVariable("localappdata") + "\background.jpg")){remove-item ([system.environment]::GetEnvironmentVariable("localappdata") + "\background.jpg")}
$localFilePath = [system.environment]::GetEnvironmentVariable("localappdata") + "\background.jpg"
#Download image to local path
Start-BitsTransfer $url -Destination $localFilePath
#Delay for propagation - This may still not be enough. If the wallpaper isn't updating, try doubling it. This is likely because of the bits transfer
Start-Sleep -s 5
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d $localFilePath /f > $null
#Set wallpaper with API
[Wallpaper.Setter]::SetWallpaper($localFilePath)
# sometimes the wallpaper only changes after the second run, so I'll run it twice!
sleep 1
[Wallpaper.Setter]::SetWallpaper($localFilePath)
#Refresh wallpaper
rundll32.exe user32.dll, UpdatePerUserSystemParameters > $null
start-sleep 600
}
