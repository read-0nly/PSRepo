<#
Morning Alarm

# Schedules to load the specified playlist at the specified time. Runs once, so it won't accidentally trigger when you're not home.
# Make sure to give youtube autoplay permissions, I suggest containers in firefox and only giving autoplay in the default container
# then mostly browsing out of another - that way autoplay doesn't trigger most of the time, only when launched by a command
# This needs to run as administrator

QOL tip: Create a shortcut with this as a command:
powershell -file "Path To This File"

Obviously, replace the path with the actual path.

#>

#Full contents of script in literal string
$ScriptBody = @"
& "C:\Program Files\Mozilla Firefox\firefox.exe" "https://www.youtube.com/watch?v=B_rndhTCy-8&list=PLQGtNNQCYxkO5JAWrCHcuRp3j8EXlLiKk"
"@

#Path to save the script
$ScriptPath = "$PSSCRIPTROOT\Task.ps1"

#Save script
$ScriptBody | out-file $ScriptPath

#Run task every day at noon
$Time = New-ScheduledTaskTrigger -At ((get-date).addDays(1).tostring().split()[0] + " " + (read-host "Wake hour (if 8:00, enter 8)") + ":00") -once

#When task runs, execute powershell and run the script
$PS = New-ScheduledTaskAction -Execute "PowerShell.exe" -argument "-file $ScriptPath"

#Run as CURRENT USER / Any User
$Principal = (New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users")

#Register task
#Cleanup task first
Unregister-ScheduledTask -TaskName "MorningAlarm" -erroraction silentlycontinue -Confirm:$false
Unregister-ScheduledTask -TaskName "MorningAlarm" -erroraction silentlycontinue -Confirm:$false
Register-ScheduledTask -TaskName "MorningAlarm" -Trigger $Time -Principal $Principal -Action $PS >> $null
