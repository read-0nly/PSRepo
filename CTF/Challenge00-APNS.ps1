#Cheap token generation, uses the intune samples scripts to generate the token then uses it to query /me. Returned token is AuthToken
#install-module azuread
$steps = @"
{
    "Entries":[
        {
            "StepType": "Config",
            "Endpoint": "https://graph.microsoft.com/v1.0/deviceManagement/applePushNotificationCertificate",
            "Method": "GET"
        }
    ]
}
"@ | convertfrom-json

. ($psscriptroot+"\GraphFunctions-new.ps1")
refreshConnection
cls
write-host "------ Set up APNS ------" -ForegroundColor Red
write-host
write-host "Just that, set it up"
write-host
write-host "Hint: https://docs.microsoft.com/en-us/mem/intune/enrollment/apple-mdm-push-certificate-get"
write-host 
write-host
$keepLooping = $true
while($keepLooping){
    $APNS = execute-step $steps.entries[0]
    if($APNS -ne $null){
        if([datetime]($apns.expirationDateTime) -gt [datetime]::Now.AddDays(30)){
            $keepLooping = $false
        }
        else{
            read-host "It exists but something's wrong. Press enter to try again"
        }
    }
    else{
        read-host "No APNS detected. Press enter to try again"
    }
}
write-host "You did it! Here's the flag:" -ForegroundColor Yellow
write-host ([System.Text.Encoding]::UTF8.getString([convert]::FromBase64String("Y3RmezdIM18zWFAxUjQ3MFJ9"))) -foregroundcolor Green