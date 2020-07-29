
$steps = @"
{
    "Entries":[
        {
            "StepType": "Config",
            "Endpoint": "https://graph.microsoft.com/beta/servicePrincipals?`$filter=appId eq '0000000a-0000-0000-c000-000000000000'",
            "Method": "GET"
        },
        {
            "StepType": "Verify",
            "Endpoint": "https://graph.microsoft.com/v1.0/me/licenseDetails",
            "Method": "GET"
        }
    ]
}
"@ | convertfrom-json

. ($psscriptroot+"\GraphFunctions-new.ps1")
refreshConnection
cls
write-host "------ Overeager Enroller ------" -ForegroundColor Red
write-host
write-host "Windows enrollment through AzureAD Join is failing"
write-host
write-host "Hint: https://docs.microsoft.com/en-us/mem/intune/enrollment/apple-mdm-push-certificate-get"
write-host 
write-host

function getMDMMAM(){
    param(
        $id
    )
    login-azurermaccount 
    $context = Get-AzureRmContext
    $tenantId = $context.Tenant.Id
    $refreshToken = $context.TokenCache.ReadItems().RefreshToken
    $body = "grant_type=refresh_token&refresh_token=$($refreshToken)&resource=74658136-14ec-4630-ad9b-26e160ff0fc6"
    $apiToken = Invoke-RestMethod "https://login.windows.net/$tenantId/oauth2/token" -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded'
 
    $header = @{
    'Authorization' = 'Bearer ' + $apiToken.access_token
    'Content-Type' = 'application/json'
        'X-Requested-With'= 'XMLHttpRequest'
        'x-ms-client-request-id'= [guid]::NewGuid()
        'x-ms-correlation-id' = [guid]::NewGuid()
    }
    $url = "https://main.iam.ad.ext.azure.com/api/MdmApplications/$id"
 
    $content = ''
    Invoke-RestMethod –Uri $url –Headers $header –Method GET #-Body $cont
}


function checkWin(){
    $IntuneApp = execute-step $steps.entries[0]
    $currentScopeDetails = getMDMMAM $IntuneApp.value.id
    $ScopeGood = (($currentScopeDetails.mdmAppliesTo -eq 2)-and(-not($currentScopeDetails.mamAppliesTo -eq 2)))
    $LicenseDetails = execute-step $steps.entries[1]
    $IntuneLicense = ($LicenseDetails.Value | %{$_.servicePlans | %{if($_.servicePlanName -like "INTUNE_A"){echo $_}}})[0]
    $LicenseStatus  = (($intuneLicense.ProvisioningStatus -ne $null) -and ($intuneLicense.ProvisioningStatus -ne "Disabled"))
    if($scopeGood -and $licensestatus){
        echo Success
    }
}

checkWin