param(
	$prefixes = @("http://localhost:80/","https://localhost:443/"),
	$responses=@{
		"/setup"="Get set up, dweeb";
		"/heartbeat"= "Ah ah ah ah staying alive staying alive";
		"/report/summary"=(@("{`"result`":`"It happened`"`}","application/json"));		
		"/report/detailed"=(@("<result message=`"Man, I don't know. You did things. A lot of them. You won doing things. Congratulations.`"><secret>Achievement Unlocked:Easter Egg</secret></result>", [System.Net.Mime.MediaTypeNames+Text]::Xml));
	}
)
#https://stackoverflow.com/questions/11403333/httplistener-class-with-https-support
function processRequest(){
	$context=$listener.GetContext();
	$request=$context.request;
	$response=$context.response;
	
	$url = $request.url	
	
	write-host $url.AbsolutePath -foregroundcolor magenta
	if($responses.containskey($url.AbsolutePath)){
		$response.statuscode = 200
		write-host ("We have a response "+$responses[$url.AbsolutePath].GetType().Name+" "+($responses[$url.AbsolutePath].GetType().Name -eq "String")+":") -foregroundcolor yellow
		if($responses[$url.AbsolutePath].GetType().Name -eq "String"){
			write-host $responses[$url.AbsolutePath]
			write-host "rawresponse" -foregroundcolor red
			$buffer=[byte[]]($responses[$url.AbsolutePath]).ToCharArray();		
		}
		else{	
			write-host $responses[$url.AbsolutePath][0]
			write-host $responses[$url.AbsolutePath][1]
			write-host "contenttyped" -foregroundcolor red
			$response.ContentType=$responses[$url.AbsolutePath][1]
			$buffer=[byte[]]($responses[$url.AbsolutePath][0]).ToCharArray();	
		}
	}else{		
		$buffer=[byte[]]("<h1>Hello world, there's nothing here</h1>").ToCharArray();
		$response.statuscode = 418
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
