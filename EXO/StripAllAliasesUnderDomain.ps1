$domain = "nullzer0.cf"
$users = get-recipient | where {$_.EmailAddresses -match "$domain"}
foreach ($user in $users)
{
    $pos = $user.PrimarySmtpAddress.IndexOf("@")
    $name = $user.PrimarySmtpAddress.Substring(0,$pos)
    if($user.RecipientTypeDetails -eq "MailUniversalDistributionGroup"){
        Set-DistributionGroup $user.identity -Emailaddresses @{Remove="smtp:$name@$domain","sip:$name@$domain"}
    }
    elseif($user.RecipientTypeDetails -eq "GroupMailbox"){
        Set-UnifiedGroup $user.identity -Emailaddresses @{Remove="smtp:$name@$domain","sip:$name@$domain"}
    }
    else{
        set-mailbox $user.identity -Emailaddresses @{Remove="smtp:$name@$domain","sip:$name@$domain"}
    }
}
