if($credential -eq $null){$credential = get-credential}

install-module msonline
install-module azuread
import-Module MSOnline
Connect-MsolService -Credential $credential
if($exchangeSession -eq $null){$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection}
Import-PSSession $ExchangeSession
cls


#Create new role and set parameters
if((Read-host "Enter 'Y' to create a new Exchange Management Role attached to the default policy that prevents the creation of autoforwarding rules by users").ToUpper() -eq "Y"){
    Get-ManagementRoleAssignment MyBaseOptions* | where-object {$_.roleAssigneeName -eq "Default Role Assignment Policy"} | Remove-ManagementRoleAssignment
    New-ManagementRole MyBaseOptions-DisableForwarding -Parent MyBaseOptions #Create new management Role
    Set-ManagementRoleEntry MyBaseOptions-DisableForwarding\Set-Mailbox -RemoveParameter -Parameters DeliverToMailboxAndForward,ForwardingAddress,ForwardingSmtpAddress #remove the ability to autoforward
    Set-ManagementRoleEntry MyBaseOptions-DisableForwarding\New-InboxRule -RemoveParameter -Parameters ForwardTo, RedirectTo, ForwardAsAttachmentTo #Remove ability to create forward rules in OWA
    Set-ManagementRoleEntry MyBaseOptions-DisableForwarding\Set-InboxRule -RemoveParameter -Parameters ForwardTo, RedirectTo, ForwardAsAttachmentTo #Remove ability to create forward rules in OWA
    New-ManagementRoleAssignment -name "MyBaseOptions-DisableForwarding-Default" -role "MyBaseOptions-DisableForwarding" -Policy "Default Role Assignment Policy"
}

#Set up Remote Domain Policies 
if((Read-host "Enter 'Y' to block autoforwarding to any domain at the Remote Domain policy level").ToUpper() -eq "Y"){
    Set-RemoteDomain Default -AutoForwardEnabled ($false)
    write-host "Default Remote Domain policy's AutoForward parameter has been disabled" -ForegroundColor Green
    while((Read-host "Enter 'Y' to create an exception policy to allow autoforwarding to a particular domain").ToUpper() -eq "Y"){
        $policyName = (read-host "Please enter a name for the new forward-enabled Remote Domain policy")        
        $policyURL = (read-host "Please enter the URL of the domain to allow forwarding for")
        $newDom = new-remotedomain -name $policyName -domainname $policyURL
        $newDom|set-remotedomain -autoforwardenabled $true        
        write-host ("New Remote Domain policy with name '"+$policyName+"' has been created and autoforward has been set to True for URL "+$policyURL) -ForegroundColor Green
    }
}

if((Read-host "Enter 'Y' to enumerate rules for review and deletion").ToUpper() -eq "Y"){
    $fileLocation = read-host "Enter the path of the folder where we should save the current configuration reports"
    #Export currently existing forward setup
    #Return all currently set forwarding inbox rules
    Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} | Select Identity,ForwardingSmtpAddress,ForwardingAddress | Export-Csv ($fileLocation+"\ForwardingSetBefore.csv") -append
    foreach ($a in (Get-Mailbox -ResultSize Unlimited |select PrimarySMTPAddress)) {Get-InboxRule -Mailbox $a.PrimarySMTPAddress | ?{($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.DeleteMessage -eq $true) -or ($_.RedirectTo -ne $null)} |select Name,Identity,ForwardTo,ForwardAsAttachmentTo, RedirectTo, DeleteMessage | Export-Csv ($fileLocation+"\InboxRules.csv") -append}

    #Flush forward setups
    $forwardedMailboxes = Get-Mailbox -ResultSize Unlimited -filter {(RecipientTypeDetails -ne "DiscoveryMailbox") -and ((ForwardingSmtpAddress -ne $null) -or (ForwardingAddress -ne $null))} 
    foreach($a in $forwardedMailboxes){
        if((read-host ("Should we delete this forwarding rule from '"+$a.primarysmtpaddress+"' to '"+(.{if($a.ForwardingSmtpAddress -ne $null){$a.ForwardingSmtpAddress} else {$a.ForwardingAddress}})    +"'?")).toupper() -eq "Y")
        {
            $mailbox = get-mailbox $a.PrimarySmtpAddress
            echo $mailbox 
            Set-Mailbox $mailbox.Id -ForwardingSmtpAddress $null -ForwardingAddress $null
        } 
    }
    
    #Flush currently set inbox rules
    foreach($a in Get-Mailbox -ResultSize Unlimited |select PrimarySMTPAddress){
        foreach($b in (Get-InboxRule -Mailbox $a.PrimarySMTPAddress | select-object * | ?{($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectTo -ne $null)}))
        {
        $forwardAddresses = (&{if($b.ForwardTo -ne $null){$b.ForwardTo+" & "}else{""}})+(&{if($b.ForwardAsAttachmentTo -ne $null){$b.ForwardAsAttachmentTo+" & "}else{""}})+(&{if($b.RedirectTo -ne $null){$b.RedirectTo+" & "}else{""}})

            if((read-host ("Should we delete this inbox rule from '"+$a.primarysmtpaddress+"' to '"+$forwardAddresses+"'?")).toupper() -eq "Y")
            {
                $b | Remove-InboxRule
            }
        }
    }
}
