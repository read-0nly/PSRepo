param(
	$prefixes = @("http://localhost:80/","https://localhost:443/"),
	$responses=@{
		"/setup"="Get set up, dweeb";
		"/heartbeat"= @("<i>Ah ah ah ah staying alive staying alive, Ah ah ah ah</i>","text/html",@{
			"staying-alii-ii-ii-" = "iiive"
		});
		"/report/summary"=(@("{`"result`":`"It happened`"`}","application/json"));		
		"/report/detailed"=(@("<result message=`"Man, I don't know. You did things. A lot of them. You won doing things. Congratulations.`"><secret>Achievement Unlocked:Easter Egg</secret></result>", [System.Net.Mime.MediaTypeNames+Text]::Xml));
	}
)
<#
HTTPS support requires a cert. use the makecert -pe flag when making the ssl cert, the root cert works as written. 
certlm, not certmgr. import from there, don't install from file.
https://stackoverflow.com/questions/11403333/httplistener-class-with-https-support
This guid works `{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7`}
#>
function processRequest(){
	$context=$listener.GetContext();
	$request=$context.request;
	$response=$context.response;
	
	$url = $request.url	
	$response.statuscode = 418
	$buffer=[byte[]]("<h1>Hello world, there's nothing here</h1>").ToCharArray();
	$response.addheader("Teapot","True")
	write-host $url.AbsolutePath -foregroundcolor magenta
	if($responses.containskey($url.AbsolutePath)){
		$response.statuscode = 200
		write-host ("We have a response "+$responses[$url.AbsolutePath].GetType().Name+" "+($responses[$url.AbsolutePath].GetType().Name -eq "String")+":") -foregroundcolor yellow
		if($responses[$url.AbsolutePath].GetType().Name -eq "String"){
			write-host $responses[$url.AbsolutePath]
			write-host "Raw Response" -foregroundcolor red
			$buffer=[byte[]]($responses[$url.AbsolutePath]).ToCharArray();		
		}
		else{	
			write-host "Complex Response" -foregroundcolor red
			write-host $responses[$url.AbsolutePath][0]
			write-host $responses[$url.AbsolutePath][1]
			$responses[$url.AbsolutePath][2].keys.split("`n")|%{
				$response.addheader($_,$responses[$url.AbsolutePath][2][$_])
			}
			$response.ContentType=$responses[$url.AbsolutePath][1]
			$buffer=[byte[]]($responses[$url.AbsolutePath][0]).ToCharArray();	
		}
	}
	$response.contentlength64=$buffer.length;
	$output=$response.outputstream;
	$output.write($buffer,0,$buffer.length)
	$output.close()
	write-host "Returning request and response" -foregroundcolor magenta
	if($responses.containskey($url.AbsolutePath)){
		$request
		$response
	}
}
$listener = [System.Net.HttpListener]::new()
$prefixes|%{$listener.Prefixes.Add($_)}
$listener.start()
do{
	write-output (processRequest)	
    if ([Console]::KeyAvailable)
    {
        $keyInfo = [Console]::ReadKey($true)
		if($keyinfo.Key -eq [ConsoleKey]::X){
			break
		}
    }
}while($true)
$listener.stop()
