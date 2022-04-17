#[System.Net.HttpListener]::IsSupported
#[Scriptblock]::Create((iwr ("https://raw.githubusercontent.com/read-0nly/PSRepo/master/Utility/remote-controlpanel.ps1?x="+(get-date).ticks) -usebasicparsing).content).Invoke(@(,@($url1,$url2),@($port,$port2)))
param(
[string[]]$URIs = @("http://localhost","http://127.0.0.1"),
[string[]]$Ports=@("80")
)

function ActivateFW(){
	#Get subnet mask
	$subnetMask = (((Get-NetIPConfiguration)[1].ipv4defaultgateway.nexthop).split(".")[0..2])+@("0/24")  -join "."

	$found = $false; 
	Get-NetFirewallRule  | %{$found = $found -or ($_.displayname -eq "AllowDashbordLAN")}; 

	if(-not $found){
		New-NetFirewallRule -DisplayName "AllowDashbordLAN" –RemoteAddress $subnetMask -Direction Inbound -Protocol TCP –LocalPort $Ports -Action Allow -Enabled "True"
	}else{
		$firewallRule = Get-NetFirewallRule -DisplayName "AllowDashbordLAN"
		$firewallRule | set-netfirewallrule -LocalPort $Ports -Enabled "True"
	}
}

function DeactivateFW(){
	#Get subnet mask
	$subnetMask = (((Get-NetIPConfiguration)[1].ipv4defaultgateway.nexthop).split(".")[0..2])+@("0/24")  -join "."

	$found = $false; 
	Get-NetFirewallRule  | %{$found = $found -or ($_.displayname -eq "AllowDashbordLAN")}; 

	if($found){
		Get-NetFirewallRule -DisplayName "AllowDashbordLAN" |set-netfirewallrule -Enabled "False"
	}
}

$URISets = $URIs | %{$uri = $_;$Ports | %{echo ($uri.ToString()+":"+$_.ToString()+"/")}}
$listener = new-object System.Net.HttpListener
$URISets | %{$listener.Prefixes.Add($_)}

$global:stopLoop = $false;
$global:defaultCommands = [PSCustomObject]@{
		"Default"=[PSCustomObject]@{
			"1_SaveMenu"=  "convertto-json `$global:commands | out-file ./actionMenu.json"
			"2_ReloadMenu"=  "`$global:commands = convertfrom-json (cat ./actionMenu.json -raw)"
			"3_ResetMenu"=  "`$global:commands = `$global:defaultCommands"
	}
}
$global:commands = $global:defaultCommands
if(test-path ./actionMenu.json) {$global:commands = convertfrom-json (cat ./actionMenu.json -raw)}

ActivateFW
$listener.Start()

while(-not $global:stopLoop){
	$context = $listener.GetContext();
	$req = $context.Request
	$rawUrl = $req.RawUrl
	$Parameters = @{}
	$rawUrl = $rawUrl.Split("?")
	$Path = $rawUrl[0]
	$rawParameters = $rawUrl[1]
	if ($rawParameters) {
		$rawParameters = $rawParameters.Split("&")
		foreach ($rawParameter in $rawParameters) {
			$Parameter = $rawParameter.Split("=")
			$Parameters.Add($Parameter[0], $Parameter[1])
		}
	}
	$resp = $context.Response
	if($parameters["stop"] -eq "stop"){
		$stopLoop = $true
		$responseStr="<h1>STOPPING</h1>"
	}else{
		if($parameters["panel"] -eq $null){
			$parameters["panel"] = "Default"
		}else{			
			if($parameters["cmd"] -ne $null){
				if($global:commands.($parameters["panel"]).($parameters["cmd"]) -ne $null){
					write-host "----"
					$global:commands.($parameters["panel"]).($parameters["cmd"])
					write-host "----"
					iex $global:commands.($parameters["panel"]).($parameters["cmd"])
				}
			}
		}
		if($true){ #Stashing the response text because big
		[string]$responseStr=@"
			<html>
				<head>
					<style type="text/css">
					body{
						background-color:#1C1B22
					}
					td{
						border:1px solid white;
						margin-left:auto;
						margin-right:auto;
						color:white;
						width:1%;
						font-size:16pt;
					}
					td:hover{
						border:3px solid #553377;
						background-color:#33224f;
						margin-left:auto;
						margin-right:auto;
						color:#AA77FF;
					}
					.lastClicked{
						border:3px solid #00ff00;
						background-color:#004f00;
						border:1px solid white;
						margin-left:auto;
						margin-right:auto;
						color:#22FF22;
					}
					table{
						text-align:center;
						font-family:sans-serif;
						border-collapse:collapse;
						width:100%;
						height:15%;
					}
					.tablehead{
						background-color:#33224f;
						color:#AA77FF;
						font-size:20pt;
						height:28px;
					}
					.buttonTable{
						background-color:#33224f;
						color:#AA77FF;
						font-size:20pt;
						height:84%;
					}
					</style>
				</head>
				<body>

					<table>
						<tbody>
							<tr>
								<td colspan="12" class="tablehead">Menu</td>
							</tr>
							<tr>
"@
		($global:commands.psobject.properties.name) | %{
			$wasclicked =""
			if($_ -eq $parameters["panel"]){$wasclicked=echo " class=`"lastClicked`""}
			$responseStr+="<td"+$wasclicked+" onClick=`"window.location=window.location.toString().split('?')[0]+'?panel=$_'`">" +
				$_ + "</td>"
			
		}
		$responseStr+=@"
							</tr>
						</tbody>
					</table>

					<table class="buttontable">
						<tbody>
							<tr>
								<td class="tablehead" colspan="12">Buttons</td>
							</tr>		
							<tr>
"@
		$i = 0
		($global:commands.($parameters["panel"]).psobject.properties.name | sort-object) | %{
			$i++
			$wasclicked =""
			if($_ -eq $parameters["cmd"]){$wasclicked=echo " class=`"lastClicked`""}
			$responseStr+="<td"+$wasclicked+" onClick=`"window.location=window.location.toString().split('?')[0]+'?cmd="+$_+"&panel="+$parameters["panel"]+"'`">" +
				$_ + "</td>"
				if(($i%4) -eq 0){$responseStr+="</tr><tr>"}
			
		}

		$responseStr+=@"
</tr>
						</tbody>
					</table>

				</body>
			</html>
"@		
		$responseStr=$responseStr.Replace("<tr></tr>","")
	}
	}
	$responseBytes= [System.Text.Encoding]::UTF8.GetBytes($responseStr);
	$resp.ContentLength64=$responseBytes.Length
	$output=$resp.OutputStream
	try{$output.Write($responseBytes,0,$responseBytes.Length)}catch{}
	$output.Close()
}
DeactivateFW
$listener.Stop();
