# Grab the terminal size - since we only check once, this will get messed up if the window
# is resized - exercise for the reader, how would you implement this so it responds properly
# to resized windows?
$global:Size = $host.UI.RawUI.BufferSize

# You're gonna want this reference: 
# https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences

function drawLine(){
	param(
		[Parameter(Mandatory=$true)]
		[string] $drawChar,
		[Parameter(Mandatory=$true)]
		[int] $drawX,
		[Parameter(Mandatory=$true)]
		[int] $drawY,
		[Parameter(Mandatory=$true)]
		[int] $drawL,
		[bool] $drawHrz = $true,
		[bool] $drawWrap = $false		
	)
	# We basically stuff the string full of control codes. When the whole string is rendered,
	# it draws the entire display
	$string = ""
	# ESC[<y>;<x>H  < Set Cursor Position
	# ESC is [char]27. Since the initial position is the same for both horizontal and vertical
	# do it outside the IF
	$string+= [char]27+"[$drawY;$drawX"+"H" 
	#Different logic depending on vertical or horizontal
	if($drawHrz){		
		# Calculate how much of the line is "off-screen"
		$diff = $global:Size.width-($drawX+$drawL)
	}
	else{
		# ESC[<n>B < Cursor Down, ESC[<n>D < Cursor Left
		# Variable to chain steps down
		$verticalStep = [char]27+"[1B" + [char]27+"[1D"
		# Calculate how much of the line is "off-screen"
		$diff = $global:Size.height-($drawY+$drawL)
		# After each drawChar we want a vertical steps
		$drawChar+=$verticalStep		
	}	
	# If the length and position renders past the screen (if the diff is negative), trim length
	if($diff -lt 0){
		# Let's chop down $drawL to the true length it can rendered
		$drawL+=$diff			
	}
	# Multiplying AB gives ABABAB
	$string+=($drawChar*$drawL)	
	# Ship the result out to either be displayed or chained
	echo $string
}
function setColor(){
	param(
		[Parameter(Mandatory=$true)]
		[int] $R,
		[Parameter(Mandatory=$true)]
		[int] $G,
		[Parameter(Mandatory=$true)]
		[int] $B,
		[Parameter(Mandatory=$true)]
		[bool] $Fore
	)	
	# Just to uh... explain what's about to happen
	# Commands between () will return their value to the equation
	# & {} < This executes the script block in place
	# What this means is that the logic as to whether this is 38 
	# or 48 is built right into the concatenation and this comment
	# ends up longer than anything it could have been. Poor Man's ternary op
	
	# ESC[38;2;<r>;<g>;<b>m  < 256 color foreground
	# ESC[48;2;<r>;<g>;<b>m  < 256 color background
	
	#Basically the switch is 38 or 48, so we want one or the other in the string.	
	echo (
		[char]27 + "[" `
		 + (& {if($fore){echo 38}else{echo 48}}).toString() `
		 + ";2;$R;$G;$B"+"m"#< Gotta isolate the m so it doesn get seen as part of the var name	 when using tokens
	 ) 
}

function demo(){
	# ESC[?1049h < Alternate Buffer
	# Think of it like having two computers tied to the same screen and switching between HDMI inputs
	# Lets you draw things without corrupting the original terminal, then switch back to it
	
	# string to hold the render. We want to render this to the alternate buffer so we can come back
	# to regular PS withough having a messed up termina when we're done.
	$render = [char]27 + "[?1049h"
	#Demo the draw line
	for ($i = 0; $i -lt 20; $i++){	
		$render += setColor (200 - ($i*10)) 0 ($i * 10) $false
		$render+= (drawLine " " ($i +5) ($i +5) 10 )
	}
	for ($i = 0; $i -lt 20; $i++){	
		$render += setColor (200 - ($i*10)) ($i * 10) 0 $false
		$render+= (drawLine " " (25-$i) (25-$i) 10 $false)
	}
	write-host $render
	read-host #< Pause for activity, then return to main buffer
	#ESC[0m < resets all formatting
	write-host ([char]27+"[0m")
	# ESC[?1049l < Main Buffer
	write-host ([char]27 + "[?1049l")
}