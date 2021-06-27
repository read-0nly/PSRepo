#Pull in the previous script
. ./colorDemo.ps1

<#
	Functions and vars inherited from previous script:
		$global:Size (Width, Height)
		drawLine([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [bool] $drawHrz, [bool] $drawWrap(unused) )
		setColor([int] $R, [int] $G, [int] $B, [bool] $Fore)
	Important VT100 codes
		ESC[?1049h < Alternate Buffer
		ESC[?1049l < Main Buffer
		ESC[0m < resets all formatting

#>

function fixBounds(){
	param(
		[Parameter(Mandatory=$true)][int]$drawX,
		[Parameter(Mandatory=$true)][int]$drawY
	)	
	# return false if out of bounds
	if($drawY -gt ($size.height-1) -or 
			($drawY -lt 0) -or 
			($drawX -gt ($size.width-1)) -or 
			($drawX -lt 0)) {		
				echo $false
		}else{echo $true}
	
}
function drawBorder(){ 
	#This'll draw 4 lines making a border who's inner volume is the given size. Because our previous line code didn't
	#check if the initial point is outside of render space, we'll handle it here
	param(
		[Parameter(Mandatory=$true)][string]$drawChar,
		[Parameter(Mandatory=$true)][int]$drawX,
		[Parameter(Mandatory=$true)][int]$drawY,
		[Parameter(Mandatory=$true)][int]$drawL,
		[Parameter(Mandatory=$true)][int]$drawH
	)
	#We want to make the border around the shape. Adjust coords
	$drawX+= -1;
	$drawY+= -1;
	$drawL+= 2;
	$drawH+= 2;
	#Render String
	$string = ""
	if((fixBounds $drawX $drawY)){
		#Draw Horizontal lines
		$string += drawLine $drawChar $drawX $drawY $drawL $true
		$string += drawLine $drawChar $drawX ($drawY+$drawH-1) ($drawL) $true 
		#Draw Vertical lines
		$string += drawLine $drawChar $drawX $drawY $drawH $false
		$string += drawLine $drawChar ($drawX+$drawL-1) $drawY ($drawH) $false 
	}
	echo $string
}
function fillBox(){ 
	#This'll draw consecutive lines making a box filled with the char. Because our previous line code didn't
	#check if the initial point is outside of render space, we'll handle it here
	param(
		[Parameter(Mandatory=$true)][string]$drawChar,
		[Parameter(Mandatory=$true)][int]$drawX,
		[Parameter(Mandatory=$true)][int]$drawY,
		[Parameter(Mandatory=$true)][int]$drawL,
		[Parameter(Mandatory=$true)][int]$drawH
	)
	#Render String
	$string = ""
	#Draw Horizontal lines in a vertical loop the height of H
	for($i=0;$i -lt $drawH; $i++){
		if((fixBounds $drawX $drawY)){
			$string += drawLine $drawChar $drawX $drawY $drawL $true
		}
		$drawY++
	}
	echo $string	
}

function demo(){
	$string = [char]27 + "[?1049h"
	$string += setColor 255 0 0 $false
	$string += drawBorder " " 2 2 3 3
	$string += setColor 128 0 128 $false
	$string += setColor 0 0 255 $true
    $string += fillBox "X" 2 2 3 3	
	#ESC [ <n> E < Cursor goes down N lines
	#give it space to breath
	$string+=[char]27+"[5E"
	write-host $string
	read-host #< Pause for activity, then return to main buffer
	#ESC[0m < resets all formatting
	write-host ([char]27+"[0m")
	# ESC[?1049l < Main Buffer
	write-host ([char]27 + "[?1049l")
}