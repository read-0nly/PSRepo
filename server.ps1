param(
	$prefixes,
	$responses=@{
		"/setup"="Get set up, dweeb";
		"/heartbeat"= "Ah ah ah ah staying alive staying alive";
		"/report/summary"="It happened";		
		"/report/detailed"="Man, I don't know. You did things. A lot of them. You won doing things. Congratulations.";
	}
)
#https://stackoverflow.com/questions/11403333/httplistener-class-with-https-support
function processRequest(){
	$context=$listener.GetContext();
	$request=$context.request;
	$url = $request.url	
	$buffer=[byte[]]("Hello world").ToCharArray();
	write-host $url.AbsolutePath -foregroundcolor magenta
	if($responses.containskey($url.AbsolutePath)){
		write-host "We have a response:" -foregroundcolor yellow
		write-host $responses[$url.AbsolutePath]
		$buffer=[byte[]]($responses[$url.AbsolutePath]).ToCharArray();		
	}
	$response=$context.response;
	$response.contentlength64=$buffer.length;
	$output=$response.outputstream;
	$output.write($buffer,0,$buffer.length)
	$output.close()
	write-host "Returning request and response" -foregroundcolor magenta
	$request
	$response
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