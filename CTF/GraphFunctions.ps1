#Cheap token generation, uses the intune samples scripts to generate the token then uses it to query /me. Returned token is AuthToken
#install-module azuread
import-module azuread

$steps = @"
{
    "Entries":[
        {
            "StepType": "Config",
            "Endpoint": "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/",
            "Method": "POST",
            "Body": "ewoJIkBvZGF0YS50eXBlIjogIiNtaWNyb3NvZnQuZ3JhcGgud2luZG93czEwRW5kcG9pbnRQcm90ZWN0aW9uQ29uZmlndXJhdGlvbiIsCgkiZGVzY3JpcHRpb24iOiAiIiwKCSJkaXNwbGF5TmFtZSI6ICJCYWRMb2NrZXIiLAoJImJpdExvY2tlckFsbG93U3RhbmRhcmRVc2VyRW5jcnlwdGlvbiI6IHRydWUsCgkiYml0TG9ja2VyRGlzYWJsZVdhcm5pbmdGb3JPdGhlckRpc2tFbmNyeXB0aW9uIjogdHJ1ZSwKCSJiaXRMb2NrZXJFbmFibGVTdG9yYWdlQ2FyZEVuY3J5cHRpb25Pbk1vYmlsZSI6IHRydWUsCgkiYml0TG9ja2VyRW5jcnlwdERldmljZSI6IHRydWUsCgkiYml0TG9ja2VyUmVjb3ZlcnlQYXNzd29yZFJvdGF0aW9uIjogImVuYWJsZWRGb3JBenVyZUFkIiwKCSJiaXRMb2NrZXJTeXN0ZW1Ecml2ZVBvbGljeSI6IHsKCQkiZW5jcnlwdGlvbk1ldGhvZCI6ICJ4dHNBZXMxMjgiLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25SZXF1aXJlZCI6IHRydWUsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvbkJsb2NrV2l0aG91dFRwbUNoaXAiOiBmYWxzZSwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtVXNhZ2UiOiAicmVxdWlyZWQiLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25UcG1QaW5Vc2FnZSI6ICJibG9ja2VkIiwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtS2V5VXNhZ2UiOiAiYmxvY2tlZCIsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvblRwbVBpbkFuZEtleVVzYWdlIjogImJsb2NrZWQiLAoJCSJtaW5pbXVtUGluTGVuZ3RoIjogNCwKCQkicHJlYm9vdFJlY292ZXJ5RW5hYmxlTWVzc2FnZUFuZFVybCI6IGZhbHNlLAoJCSJwcmVib290UmVjb3ZlcnlNZXNzYWdlIjogbnVsbCwKCQkicHJlYm9vdFJlY292ZXJ5VXJsIjogbnVsbCwKCQkicmVjb3ZlcnlPcHRpb25zIjogewoJCQkiYmxvY2tEYXRhUmVjb3ZlcnlBZ2VudCI6IHRydWUsCgkJCSJyZWNvdmVyeVBhc3N3b3JkVXNhZ2UiOiAicmVxdWlyZWQiLAoJCQkicmVjb3ZlcnlLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkJImhpZGVSZWNvdmVyeU9wdGlvbnMiOiB0cnVlLAoJCQkiZW5hYmxlUmVjb3ZlcnlJbmZvcm1hdGlvblNhdmVUb1N0b3JlIjogdHJ1ZSwKCQkJInJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogInBhc3N3b3JkT25seSIsCgkJCSJlbmFibGVCaXRMb2NrZXJBZnRlclJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogdHJ1ZQoJCX0KCX0sCgkiYml0TG9ja2VyRml4ZWREcml2ZVBvbGljeSI6IHsKCQkiZW5jcnlwdGlvbk1ldGhvZCI6ICJ4dHNBZXMxMjgiLAoJCSJyZXF1aXJlRW5jcnlwdGlvbkZvcldyaXRlQWNjZXNzIjogdHJ1ZSwKCQkicmVjb3ZlcnlPcHRpb25zIjogewoJCQkiYmxvY2tEYXRhUmVjb3ZlcnlBZ2VudCI6IHRydWUsCgkJCSJyZWNvdmVyeVBhc3N3b3JkVXNhZ2UiOiAicmVxdWlyZWQiLAoJCQkicmVjb3ZlcnlLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkJImhpZGVSZWNvdmVyeU9wdGlvbnMiOiB0cnVlLAoJCQkiZW5hYmxlUmVjb3ZlcnlJbmZvcm1hdGlvblNhdmVUb1N0b3JlIjogdHJ1ZSwKCQkJInJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogInBhc3N3b3JkT25seSIsCgkJCSJlbmFibGVCaXRMb2NrZXJBZnRlclJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogdHJ1ZQoJCX0KCX0sCgkiYml0TG9ja2VyUmVtb3ZhYmxlRHJpdmVQb2xpY3kiOiB7CgkJImVuY3J5cHRpb25NZXRob2QiOiAiYWVzQ2JjMTI4IiwKCQkicmVxdWlyZUVuY3J5cHRpb25Gb3JXcml0ZUFjY2VzcyI6IHRydWUsCgkJImJsb2NrQ3Jvc3NPcmdhbml6YXRpb25Xcml0ZUFjY2VzcyI6IGZhbHNlCgl9Cn0="
        },
        {
            "StepType": "Verify",
            "Endpoint": "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/",
            "Method": "GET",
            "ExpectedResult": "ewoJIkBvZGF0YS50eXBlIjogIiNtaWNyb3NvZnQuZ3JhcGgud2luZG93czEwRW5kcG9pbnRQcm90ZWN0aW9uQ29uZmlndXJhdGlvbiIsCgkiZGVzY3JpcHRpb24iOiAiIiwKCSJkaXNwbGF5TmFtZSI6ICJCYWRMb2NrZXIiLAoJImJpdExvY2tlckFsbG93U3RhbmRhcmRVc2VyRW5jcnlwdGlvbiI6IHRydWUsCgkiYml0TG9ja2VyRGlzYWJsZVdhcm5pbmdGb3JPdGhlckRpc2tFbmNyeXB0aW9uIjogdHJ1ZSwKCSJiaXRMb2NrZXJFbmNyeXB0RGV2aWNlIjogdHJ1ZSwKCSJiaXRMb2NrZXJTeXN0ZW1Ecml2ZVBvbGljeSI6IHsKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uUmVxdWlyZWQiOiB0cnVlLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25CbG9ja1dpdGhvdXRUcG1DaGlwIjogZmFsc2UsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvblRwbVVzYWdlIjogInJlcXVpcmVkIiwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtUGluVXNhZ2UiOiAiYmxvY2tlZCIsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvblRwbUtleVVzYWdlIjogImJsb2NrZWQiLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25UcG1QaW5BbmRLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkicmVjb3ZlcnlPcHRpb25zIjogewoJCQkicmVjb3ZlcnlQYXNzd29yZFVzYWdlIjogInJlcXVpcmVkIiwKCQkJInJlY292ZXJ5S2V5VXNhZ2UiOiAiYmxvY2tlZCIsCgkJCSJoaWRlUmVjb3ZlcnlPcHRpb25zIjogdHJ1ZSwKCQkJImVuYWJsZVJlY292ZXJ5SW5mb3JtYXRpb25TYXZlVG9TdG9yZSI6IHRydWUsCgkJCSJyZWNvdmVyeUluZm9ybWF0aW9uVG9TdG9yZSI6ICJwYXNzd29yZE9ubHkiCgkJfQoJfSwKCSJiaXRMb2NrZXJGaXhlZERyaXZlUG9saWN5IjogewoJCSJyZWNvdmVyeU9wdGlvbnMiOiB7CgkJCSJyZWNvdmVyeVBhc3N3b3JkVXNhZ2UiOiAicmVxdWlyZWQiLAoJCQkicmVjb3ZlcnlLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkJImhpZGVSZWNvdmVyeU9wdGlvbnMiOiB0cnVlLAoJCQkiZW5hYmxlUmVjb3ZlcnlJbmZvcm1hdGlvblNhdmVUb1N0b3JlIjogdHJ1ZSwKCQkJInJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogInBhc3N3b3JkT25seSIKCQl9Cgl9Cn0="
        }
    ]
}
"@ | convertfrom-json

function refreshConnection(){
$Tenant = (iex (iwr "https://raw.githubusercontent.com/microsoftgraph/powershell-intune-samples/master/CompanyPortalBranding/CompanyPortal_Get.ps1" -usebasicparsing).content)

write-host "Connected to : " -ForegroundColor Green -NoNewline
write-host ($Tenant.displayName) -ForegroundColor Magenta

$uri = "https://graph.microsoft.com/beta/me"
write-host ("Hello, "+(Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).displayName) -foregroundcolor yellow
}

function execute-Step(){
    param(
        [pscustomobject] $step
    )
    PSObj2Hashtable (Invoke-RestMethod -Uri $step.Endpoint -Headers $authToken -Method $step.Method -Body ([System.Text.Encoding]::UTF8.getString([convert]::FromBase64String($step.Body))));
}

function verify-Step(){
    param(
        [pscustomobject]$step,
        [pscustomobject]$result
    )
    $Compare = PSObj2Hashtable (([System.Text.Encoding]::UTF8.getString([convert]::FromBase64String($step.ExpectedResult))) | convertfrom-json)
}

function hashCompare(){
    param($result,$expectedresult)
    $Success = $true
    $expectedresult.keys.split("`n") | %{
        if($expectedresult[$_].getType().name -eq "Hashtable"){
            $success = ($success -and (hashCompare $result[$_] $expectedresult[$_]))
        }
        else{
            $success = ($success -and ($result[$_] -eq $expectedresult[$_]))
        }
    }
    return ($success)

}

#Helper function - turns the imported PSCustomObject to a Hashtable
function PSObj2Hashtable(){
    param($PSObj)
    $PSObj2Hashtable = @{}
    $Keys = ($PSObj| Get-Member | where-object {$_.MemberType -eq "NoteProperty"}).Name
    $Keys | %{
        $valueFetch = [scriptblock]::Create(('param($PSObj); echo ($PSObj."'+$_+'")'));
        $value = (Invoke-Command $valueFetch -ArgumentList $PSObj)
        if($value -ne $null -and $value.gettype().name -eq "PSCustomObject"){
            $value = (PSObj2Hashtable $value)
        }
        $PSObj2Hashtable.add($_,$value);

    }
    return $PSObj2Hashtable
}

