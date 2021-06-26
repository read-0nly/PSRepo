param($path)

add-type -AssemblyName system.drawing
add-type -AssemblyName system.windows.forms

$global:origImageBytes = [System.IO.File]::ReadAllBytes( (&{if($path){echo $path}else{(read-host "Path to file to glitch").replace('"',"")}}))
$global:origImageImg = (new-object system.drawing.ImageConverter).ConvertFrom($global:origImageBytes);
$global:CorruptedBytes = $global:origImageBytes.clone();
$global:WorkingBytes = $global:CorruptedBytes.clone()
$global:Position = 0;
$global:Data = [byte[]]@(,0);
$global:LastError = "";
$global:command = ""

$global:Form = new-object system.windows.forms.form
$global:Form.width = 300;
$global:Form.height = 300;

$global:label = new-object system.windows.forms.label
$global:label.autosize = $false
$global:label.width = 290;
$global:label.height = 290;
$global:label.backgroundimagelayout = 4
$global:label.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom +[System.Windows.Forms.AnchorStyles]::top +[System.Windows.Forms.AnchorStyles]::Left +[System.Windows.Forms.AnchorStyles]::right

$global:editButton = new-object system.windows.forms.button
$global:editButton.width = 100;
$global:editButton.height = 30;
$global:editButton.top = 220;
$global:editButton.left = 10;
$global:editButton.text = "Edit";
$global:editButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom  +[System.Windows.Forms.AnchorStyles]::left

$global:Form.Controls.Add($global:editButton)
$global:Form.Controls.Add($global:label)

$global:Form.width = 1000;
$global:Form.height = 600;

<#
$global:form.show();
$timer = new-object timers.timer
$action = {[System.Windows.Forms.Application]::DoEvents()} 
$timer.Interval = 240 #0.1 seconds 
unregister-Event *
Register-ObjectEvent -InputObject $timer -EventName elapsed –SourceIdentifier thetimer -Action $action
$timer.start();#>
function preview(){
	param(
		$img
	)
	
	$global:label.backgroundimage = $img
}

function showMenu(){	
	write-host ("Current position:"+$global:Position)
	write-host ("Current Data:"+$global:data)
	write-host ("Current Data (string):"+(-join [char[]]$global:data))
	write-host ("File Length:"+($global:workingbytes.count))
	write-host ""
	$Percent = [int](($global:position/($global:workingbytes.count))*100)		
	write-host ("["+("X"*$percent)+(" "*(100-$percent))+"]")
	write-host ""
	write-host $global:LastError -foregroundcolor red
	$global:LastError = ""
	write-host ""		
	write-host "[+0]: Move forward; [-0]: Move back; [`"string]: Set data; [#]: HashString;[?] Apply/Preview; [>]: Confirm; [S]: Save"
	$global:command = read-host "Enter command"
}

preview $origImageImg

$global:editButton.add_Click({
	$Apply = $false
	while(-not $Apply){	
		cls
		showMenu
		$commandTag = (-join ($global:command[1..($global:command.length-1)]))
		switch(([string]$global:command[0]).toupper()){
			"+" {
				try{
					if(($global:position+([int]$commandTag)+$global:data.count) -lt $global:workingbytes.count){
						$global:Position +=[int]$commandTag		
					}
					else{
						$global:LastError = "Please enter an amount within bounds"
					}
				}
				catch{					
					$global:LastError = "Please enter a valid amount"
				}
			}
			"-" {
				try{
					if(($global:position-([int]$commandTag)) -gt 0){
						$global:Position += 0-([int]$commandTag)		
					}
					else{
						$global:LastError = "Please enter an amount within bounds"
					}
				}
				catch{					
					$global:LastError = "Please enter a valid amount"
				}
			}
			"`"" {
				$global:Data = [byte[]][char[]]$commandTag
			}
			"?"{								
				$global:WorkingBytes = $global:CorruptedBytes.clone()
				try{
					if(($global:position+$global:data.count) -lt $global:workingbytes.count){
						for($i = $global:position; $i -lt ($global:position+$global:data.count); $i++){
							$global:workingbytes[$i] = $global:data[$i-$global:position];
						}
					}
					preview (new-object system.drawing.ImageConverter).ConvertFrom($global:WorkingBytes);
					$apply = $true
				}
				catch{
					$global:WorkingBytes = $global:CorruptedBytes.clone()
					$global:LastError = "File too corrupt to open, reverted"
				}
			}
			"#" {
				$global:Data = [byte[]] -split ($commandTag -replace '..', '0x$& ')
			}
			">" {
				$global:CorruptedBytes = $global:WorkingBytes.clone()
				$apply = $true
			}
			"S" {				
				[System.IO.File]::WriteAllBytes((read-host "Enter a valid file path"),$global:CorruptedBytes)
				$apply = $true
			}
			default {
				$apply = $true
			}
		}
	}
	cls
	write-host "Previewing" -foregroundcolor green
})

	$global:form.showDialog();
