##Shamelessly stolen from http://rubli.info/t-blog/2011/06/29/querying-key-states-in-powershell/
function Get-KeyState([uint16]$keyCode)
{
  $signature = '[DllImport("user32.dll")]public static extern short GetKeyState(int nVirtKey);'
  $type = Add-Type -MemberDefinition $signature -Name User32 -Namespace GetKeyState -PassThru
  return [bool]($type::GetKeyState($keyCode) -band 0x80)
} 

#Loop switch
$loopSw = $true
$score = $retainedScore
#Player Config
$spawnPlayer = @{
	Icon = "[>";
	Color="Red";
	X=0;
	Y=0;
	FireState = 0;
	Score = 0;
}

$Players = @{}
$Players.add($SpawnPlayer.Color, $SpawnPlayer)

#Ray Config
$spawnRay = @{
	Head="-";
	Tail=":";
	HeadColor="Yellow";
	TailColor=@("DarkRed", "Red");
	X=-1;
	Y=-1;
	Velocity = 1;
	spawnFrame = 0;
}
$Rays = @{}

#Asteroid Config
$spawnAsteroid = @{
	Icon = "@"; 
	Color = "Gray"; 
	X = -1; 
	Y = -1; 
	Velocity = 3
	spawnRate = 10
	spawnFrame = 0
}
$Asteroids = @{}

$FPS = 30
#Milliseconds per frame
#Milliseconds per frame
$MsPF = 1000/$fps

#Total frames since game start
$FrameCount = 0

#Keycodes for key detection
$gameKeys=@{
Fire = 0x58;
Up = 0x57;
Down = 0x53;
Left = 0x41;
Right = 0x44
}

#Resolution
$ScreenX = 100
$ScreenY = 30


#Basic Display config
$Monitor = @()
$BlankMonitor = @()
$BlankChar = " "
$updateRows = @()
$Blank = ""

#Background
$BaseColor = "Black"

#Generate init display
$intTrash = 0
$i2 = 0
while($intTrash -lt $ScreenX){
		$Blank += $BlankChar
		$intTrash++
	}
#Generate empty screen
while($i2 -lt $ScreenY){
	$Monitor+= @(,$Blank.toCharArray().clone())
	$i2++
	
}

while($loopSw){
	#Start preparing next frame by clearing it
	$frameStart = (get-date).millisecond
	#Detect key state
	if(get-keystate($gameKeys.Fire)){
		switch ($players["Red"].FireState){
			0 { $players["Red"].FireState = 1 
			
			$newRay = $SpawnRay.clone()
			$newRay.spawnFrame = $frameCount
			$newRay.X = 2
			$newRay.Y = $players["Red"].Y
			$Rays.add(($newRay.spawnFrame).toString(), $newRay)
		}
			1 { }
		}
	}
	else {
		switch ($players["Red"].FireState){
			0 { }
			1 { $players["Red"].Firestate = 0 }
		}
	}


	if(get-keystate($gameKeys.Up)){
		if($Players["Red"].Y -gt 0){
			$Players["Red"].Y--
		}
	}
	if(get-keystate($gameKeys.Down)){
		if($Players["Red"].Y -lt $ScreenY-1){
			$Players["Red"].Y++
		}
	}

	$i = 0
	$Monitor = @()
	while($i -lt $ScreenY){
		$Monitor+= @(,$Blank.toCharArray().clone())
		$i++
		
	}

#Asteroid spawn
	if(($FrameCount % $spawnAsteroid.spawnRate) -eq 0){
		$newAsteroid = $SpawnAsteroid.clone()
		$newAsteroid.spawnFrame = $frameCount
		$newAsteroid.X = $ScreenX-1
		$newAsteroid.Y = (get-random -minimum 0 -maximum $ScreenY)
		$Asteroids.add(($newAsteroid.spawnFrame).toString(), $newAsteroid)
	}

	foreach ($a in ($Asteroids.values)){
		if (($frameCount % $a.Velocity)-eq 0){ 
			$a.X--			
		}
		if($a.X -lt 1){
				$Asteroids.remove($a.spawnFrame.toString())
				$loopSw = $false
		}
		else{
			$Monitor[$a.Y][$a.X] = $a.Icon.toCharArray()[0]
		}
	}
	$RayDelete=@()
	foreach ($r in ($Rays.values)){
		if(($Monitor[$r.Y][$r.X+1] -eq '@') -or ($Monitor[$r.Y][$r.X+2] -eq '@')){	
			$A1 = $Asteroids.values | where-object {$_.Y -eq $r.Y}
			$A2 = $A1 | where-object {$_.X -lt $r.X+3}
			if($A2.length -eq 1){			
				$Asteroids.remove($A2.spawnFrame.toString())
				$score += (100 - $A2.X)+$fps
				$raydelete+=@(,$r.spawnFrame.toString())
			} 
			else{
				$Asteroids.remove($A2[0].spawnFrame.toString())
				$raydelete+=@(,$r.spawnFrame.toString())
				$score += $ScreenX - $A2[0].X
			}
		}
		else
		{
			if (($frameCount % $r.Velocity) -eq 0){ 
				$r.X++
			}
		
			if(-not ($r.X -lt $screenX)){
				$raydelete+=@(,$r.spawnFrame.toString())
				$score+=0-10
				$retainedScore = $score - 2000
				if($retainedScore -lt 0){
					$retainedScore = 0
				}
			}
			else{
				$Monitor[$r.Y][$r.X] = $r.Head.toCharArray()[0]
			}
		}
	}
	foreach($r in $RayDelete){
		$Rays.remove($r)	
	}
	foreach ($p in ($Players.Values)){
		$i=0
		foreach($char in $p.icon.toCharArray()){
			$Monitor[$P.Y][$P.X+$i] = $P.Icon.toCharArray()[$i]
			$i++
		}
	}
	$scoreStr=("Score:" + $Score)
	$astStr=("Meteors:" +$Asteroids.count)
	$rayStr=("Rays:" +$rays.count)
	$PlayStr=("Players:" +$players.count)
	$disStr = $null
	$disStr = ($scoreStr.padRight(14)+$astStr.padRight(14)+$rayStr.padRight(14)+$PlayStr.padRight(14)).padRight($ScreenX) + "`r`n"
	$disStr += "-".padRight($screenX, "-")+"`r`n"
	foreach($M in $Monitor){
		$disStr += (-join $M)+"`r`n"
	}
	$disStr += "-".padRight($screenX, "-")+"`r`n"
	
	cls
	write-host $disStr -BackgroundColor $BaseColor
	$FrameCount++
	start-sleep -m (1000/$FPS)
}


