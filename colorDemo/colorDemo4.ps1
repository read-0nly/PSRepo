#Pull in the previous script
. ./colorDemo3.ps1

<#
	Functions and vars inherited from previous script:
		$global:Size (Width, Height)
		drawLine([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [bool] $drawHrz, [bool] $drawWrap(unused) )
		setColor([int] $R, [int] $G, [int] $B, [bool] $Fore)
		
		fixBounds([int] $drawX, [int] $drawY)
		drawBorder([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [int] $drawH) < Adjusts so that the internal empty volume is size of coords given
		fillBox([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [int] $drawH) <The idea is border first, then fill, and both can be based off size calc'd from text
		
		drawText([string]$drawStr, [int]$drawX, [int]$drawY, [int]$drawL, [int]$drawAlign)
		
	Important VT100 codes
		ESC[?1049h < Alternate Buffer
		ESC[?1049l < Main Buffer
		ESC[0m < resets all formatting
		ESC[<n>E < Cursor goes down N lines
		
	$ofs = "" so char arrays get auto-joined
#>
function fillText(){ 
	# This'll fill a box of text (doing fillbox with spaces first to set the background of the box)
	# Same as drawtext, but with additional wordwrap logic - it largely uses drawtext in fact
	param(
		[Parameter(Mandatory=$true)][string]$drawStr,
		[Parameter(Mandatory=$true)][int]$drawX,
		[Parameter(Mandatory=$true)][int]$drawY,
		[Parameter(Mandatory=$true)][int]$drawL,
		[Parameter(Mandatory=$true)][int]$drawH,
		[Parameter(Mandatory=$true)][int]$drawAlign, # 0=center, -1 left align, 1 right align
		[bool]$wordWrap = $false
	)
	$drawStrArr = $drawStr.replace("`r","").split("`n")
	$string=""
	for($i =0; $i -lt $drawH; $i++){
		if($drawStrArr[$i]){
			$string+=drawText ($drawStrArr[$i]) $drawX ($drawY + $i) $drawL $drawAlign
		}
		else{
			$string+=drawText (" ") $drawX ($drawY + $i) $drawL $drawAlign
		}
	}	
	return $string
}

function demo(){
	$input = @"
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
minim veniam, quis nostrud exercitation
ullamco laboris nisi ut
aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore
eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
non proident, sunt in culpa qui officia deserunt mollit
anim id est laborum.
"@
	
	write-host ([char]27+"[0m")
	$string = [char]27 + "[?1049h"
	
	$Menu = @("`nHome`n",
	"`nSomething`n",
	"`nSomething else`n",
	"`nAbout`n",
	"`nContact`n")
	$menuColor = (setColor 128 0 196 $false) + (setColor 224 128 255 $true)
	$MenuWidth = 20
	$Header = "`nThis is a TUI demo`n"
	$headerColor = (setColor 0 128 96 $false) + (setColor 124 255 196 $true)
	$loremColor = (setColor 255 255 255 $false) + (setColor 0 0 0 $true)
	$secondWidth = $Size.width - $menuwidth - 3
	$height = $size.height - 2
	
	$borderColor = (setColor 50 50 50 $false)
	$string +=$borderColor
	
	for($i = 0; $i -lt $menu.count; $i++){
		$string +=drawBorder " " 1 (5+($i*4)) $menuwidth 3
	}
	$string +=drawBorder " " ($menuwidth + 2) 1 ($size.width - ($menuwidth+3)) 3
	$string +=drawBorder " " ($menuwidth + 2) 5 ($size.width - ($menuwidth+3)) $height 
	
	$string +=$menuColor	
	for($i = 0; $i -lt $menu.count; $i++){
		$string +=fillText $menu[$i] 1 (5+($i*4)) $menuwidth 3 0
	}
	$string +=$headerColor	
	$string +=fillText $header ($menuwidth + 2) 1 ($size.width - ($menuwidth+2)) 3 1
	$string +=$loremColor	
	$string +=fillText $input ($menuwidth + 2) 5 ($size.width - ($menuwidth+2)) $height -1
	$string+=[char]27+"[$drawY;$drawX"+"H" 
	$string
	
	read-host #< Pause for activity, then return to main buffer
	
	#ESC[0m < resets all formatting
	write-host ([char]27+"[0m")
	# ESC[?1049l < Main Buffer
	write-host ([char]27 + "[?1049l")
	
	
}