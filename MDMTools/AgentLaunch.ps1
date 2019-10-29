$scriptPath = read-host "Enter the path to the script file to execute"
$logFolder = read-host "Enter the path to a folder to output the logs to"
$outputPath = $logFolder+"\output.output"
$errorPath =  $logFolder+"\error.error"
$timeoutPath =  $logFolder+"\timeout.timeout"
$timeoutVal = 60000 
$PSFolder = "C:\Windows\SysWOW64\WindowsPowerShell\v1.0"
$AgentExec = "C:\Program Files (x86)\Microsoft Intune Management Extension\agentexecutor.exe"
&$AgentExec -powershell  $scriptPath $outputPath $errorPath $timeoutPath $timeoutVal $PSFolder 0 0
