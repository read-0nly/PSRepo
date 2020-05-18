<#
This snippet adds easy powershell session logging to any snippet. The file gets saved to desktop as PowershellLog_000000000.txt, and should have a 
unique name every time since it's based on the current tick, to the millisecond."Echo" or "Write-host" things that you want explicitly logged.
#>
$startTickcode = ((get-date).ticks.tostring()[-1..-10] | % -begin {$x = ""} {$x += $_ } -end {echo $x} #Generate a unique timecode from the last 10 digits of the current "tick"
$logfile = [system.environment]::GetFolderPath("desktop") + "\PowershellLog_" + $startTickcode + ".txt" #Unique file name for new log file
start-transcript -path $logfile -NoClobber  #Start logging
############ Place snippet below this header ############
############ Place snippet above this header ############
stop-transcript #Stop transcripting log
