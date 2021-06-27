#Pull in the previous script
. ./colorDemo2.ps1

<#
	Functions and vars inherited from previous script:
		$global:Size (Width, Height)
		drawLine([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [bool] $drawHrz, [bool] $drawWrap(unused) )
		setColor([int] $R, [int] $G, [int] $B, [bool] $Fore)
		
		fixBounds([int] $drawX, [int] $drawY)
		drawBorder([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [int] $drawH) < Adjusts so that the internal empty volume is size of coords given
		fillBox([string] $drawChar, [int] $drawX, [int] $drawY, [int] $drawL, [int] $drawH) <The idea is border first, then fill, and both can be based off size calc'd from text
		
	Important VT100 codes
		ESC[?1049h < Alternate Buffer
		ESC[?1049l < Main Buffer
		ESC[0m < resets all formatting
		ESC[<n>E < Cursor goes down N lines
#>

$ofs = ""
function drawText(){ 
	#This'll draw text to the screen, in both directions, within a set length, with alignment deciding if
	# it's left, right, or center aligned
	param(
		[Parameter(Mandatory=$true)][string]$drawStr,
		[Parameter(Mandatory=$true)][int]$drawX,
		[Parameter(Mandatory=$true)][int]$drawY,
		[Parameter(Mandatory=$true)][int]$drawL,
		[Parameter(Mandatory=$true)][int]$drawAlign, # 0=center, -1 left align, 1 right align
		[bool]$drawHoriz = $true #Exercise for the reader :P
	)
	# Calculate how much of the line is "off-screen"
	$diff = $global:Size.width-($drawX+$drawL)
	
	
	# If the length and position renders past the screen (if the diff is negative), trim length
	if($diff -lt 0){
		# Let's chop down $drawL to the true length it can rendered
		$drawL+=$diff			
	}
	
	$string = ""
	if(fixBounds $drawX $drawY){
		$string+= [char]27+"[$drawY;$drawX"+"H" 
		
		switch($drawAlign){
			{$_ -lt 0}{
				if($drawStr.length -gt $drawL){
					$string+=[string]$drawStr[0..($drawL-1)]
				}
				else{
					$diff =  $drawL - $drawStr.length 
					$string+=$drawStr	
					$string+=(" " * $diff)
				}
			}
			{$_ -gt 0}{
				if($drawStr.length -gt $drawL){
					$diff = $drawStr.length - $drawL
					$string+= $drawStr[$diff..($drawL+$diff-1)]
				}
				else{
					$diff = $drawL - $drawStr.length
					$string+=(" " * $diff)
					$string+=$drawStr					
				}
			}
			{$_ -eq 0}{
				if($drawStr.length -gt $drawL){
					$diff = $drawStr.length - $drawL
					$diff = [Math]::Floor($diff/2)
					$string += (-join ($drawStr[$diff..($drawL+$diff-1)]))
				}
				else{
					$diff = $drawL - $drawStr.length
					$diff2 = [Math]::Ceiling($diff/2)
					$diff = [Math]::Floor($diff/2)
					$string += (" "*$diff)+$drawStr+(" "*$diff2)
				}
				
			}
		}
	}
	echo $string
}
function demo(){
	$string = [char]27 + "[?1049h"
	$string += setColor 255 0 0 $false
	$string += setColor 0 0 0 $true
	$string += drawText "Hello World" 10 0 11 -1	
	$string += drawText "Hello World" 8 3 3 -1
	$string += drawText "Hello World" 9 4 3 0
	$string += drawText "Hello World" 10 5 3 1
	$string += setColor 128 0 255 $false
	$string += setColor 196 128 255 $true
	$string += drawText "Hello World" 10 9 15 -1
	$string += drawText "Hello World" 9 10 15 0
	$string += drawText "Hello World" 8 11 15 1
	
	
	write-host $string
	read-host #< Pause for activity, then return to main buffer
	#ESC[0m < resets all formatting
	write-host ([char]27+"[0m")
	# ESC[?1049l < Main Buffer
	write-host ([char]27 + "[?1049l")
}