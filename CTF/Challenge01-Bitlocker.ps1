#Cheap token generation, uses the intune samples scripts to generate the token then uses it to query /me. Returned token is AuthToken
#install-module azuread
$steps = @"
{
    "Entries":[
        {
            "StepType": "Config",
            "Endpoint": "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/",
            "Method": "POST",
            "Body": "ewoJIkBvZGF0YS50eXBlIjogIiNtaWNyb3NvZnQuZ3JhcGgud2luZG93czEwRW5kcG9pbnRQcm90ZWN0aW9uQ29uZmlndXJhdGlvbiIsCgkiZGVzY3JpcHRpb24iOiAiIiwKCSJkaXNwbGF5TmFtZSI6ICJCYWRMb2NrZXIiLAoJImJpdExvY2tlckFsbG93U3RhbmRhcmRVc2VyRW5jcnlwdGlvbiI6IHRydWUsCgkiYml0TG9ja2VyRGlzYWJsZVdhcm5pbmdGb3JPdGhlckRpc2tFbmNyeXB0aW9uIjogdHJ1ZSwKCSJiaXRMb2NrZXJFbmFibGVTdG9yYWdlQ2FyZEVuY3J5cHRpb25Pbk1vYmlsZSI6IHRydWUsCgkiYml0TG9ja2VyRW5jcnlwdERldmljZSI6IHRydWUsCgkiYml0TG9ja2VyUmVjb3ZlcnlQYXNzd29yZFJvdGF0aW9uIjogImVuYWJsZWRGb3JBenVyZUFkIiwKCSJiaXRMb2NrZXJTeXN0ZW1Ecml2ZVBvbGljeSI6IHsKCQkiZW5jcnlwdGlvbk1ldGhvZCI6ICJ4dHNBZXMxMjgiLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25SZXF1aXJlZCI6IHRydWUsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvbkJsb2NrV2l0aG91dFRwbUNoaXAiOiBmYWxzZSwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtVXNhZ2UiOiAicmVxdWlyZWQiLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25UcG1QaW5Vc2FnZSI6ICJhbGxvd2VkIiwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtS2V5VXNhZ2UiOiAiYWxsb3dlZCIsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvblRwbVBpbkFuZEtleVVzYWdlIjogImFsbG93ZWQiLAoJCSJtaW5pbXVtUGluTGVuZ3RoIjogNCwKCQkicHJlYm9vdFJlY292ZXJ5RW5hYmxlTWVzc2FnZUFuZFVybCI6IGZhbHNlLAoJCSJwcmVib290UmVjb3ZlcnlNZXNzYWdlIjogbnVsbCwKCQkicHJlYm9vdFJlY292ZXJ5VXJsIjogbnVsbCwKCQkicmVjb3ZlcnlPcHRpb25zIjogewoJCQkiYmxvY2tEYXRhUmVjb3ZlcnlBZ2VudCI6IHRydWUsCgkJCSJyZWNvdmVyeVBhc3N3b3JkVXNhZ2UiOiAicmVxdWlyZWQiLAoJCQkicmVjb3ZlcnlLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkJImhpZGVSZWNvdmVyeU9wdGlvbnMiOiB0cnVlLAoJCQkiZW5hYmxlUmVjb3ZlcnlJbmZvcm1hdGlvblNhdmVUb1N0b3JlIjogdHJ1ZSwKCQkJInJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogInBhc3N3b3JkT25seSIsCgkJCSJlbmFibGVCaXRMb2NrZXJBZnRlclJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogdHJ1ZQoJCX0KCX0sCgkiYml0TG9ja2VyRml4ZWREcml2ZVBvbGljeSI6IHsKCQkiZW5jcnlwdGlvbk1ldGhvZCI6ICJ4dHNBZXMxMjgiLAoJCSJyZXF1aXJlRW5jcnlwdGlvbkZvcldyaXRlQWNjZXNzIjogdHJ1ZSwKCQkicmVjb3ZlcnlPcHRpb25zIjogewoJCQkiYmxvY2tEYXRhUmVjb3ZlcnlBZ2VudCI6IHRydWUsCgkJCSJyZWNvdmVyeVBhc3N3b3JkVXNhZ2UiOiAicmVxdWlyZWQiLAoJCQkicmVjb3ZlcnlLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkJImhpZGVSZWNvdmVyeU9wdGlvbnMiOiB0cnVlLAoJCQkiZW5hYmxlUmVjb3ZlcnlJbmZvcm1hdGlvblNhdmVUb1N0b3JlIjogdHJ1ZSwKCQkJInJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogInBhc3N3b3JkT25seSIsCgkJCSJlbmFibGVCaXRMb2NrZXJBZnRlclJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogdHJ1ZQoJCX0KCX0sCgkiYml0TG9ja2VyUmVtb3ZhYmxlRHJpdmVQb2xpY3kiOiB7CgkJImVuY3J5cHRpb25NZXRob2QiOiAiYWVzQ2JjMTI4IiwKCQkicmVxdWlyZUVuY3J5cHRpb25Gb3JXcml0ZUFjY2VzcyI6IHRydWUsCgkJImJsb2NrQ3Jvc3NPcmdhbml6YXRpb25Xcml0ZUFjY2VzcyI6IGZhbHNlCgl9Cn0="
        },
        {
            "StepType": "Verify",
            "Endpoint": "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/?`$filter=startswith(displayName,'BadLocker')",
            "Method": "GET",
            "ExpectedResult": "ewoJIkBvZGF0YS50eXBlIjogIiNtaWNyb3NvZnQuZ3JhcGgud2luZG93czEwRW5kcG9pbnRQcm90ZWN0aW9uQ29uZmlndXJhdGlvbiIsCgkiYml0TG9ja2VyQWxsb3dTdGFuZGFyZFVzZXJFbmNyeXB0aW9uIjogdHJ1ZSwKCSJiaXRMb2NrZXJEaXNhYmxlV2FybmluZ0Zvck90aGVyRGlza0VuY3J5cHRpb24iOiB0cnVlLAoJImJpdExvY2tlckVuY3J5cHREZXZpY2UiOiB0cnVlLAoJImJpdExvY2tlclN5c3RlbURyaXZlUG9saWN5IjogewoJCSJzdGFydHVwQXV0aGVudGljYXRpb25SZXF1aXJlZCI6IHRydWUsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvbkJsb2NrV2l0aG91dFRwbUNoaXAiOiBmYWxzZSwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtVXNhZ2UiOiAicmVxdWlyZWQiLAoJCSJzdGFydHVwQXV0aGVudGljYXRpb25UcG1QaW5Vc2FnZSI6ICJibG9ja2VkIiwKCQkic3RhcnR1cEF1dGhlbnRpY2F0aW9uVHBtS2V5VXNhZ2UiOiAiYmxvY2tlZCIsCgkJInN0YXJ0dXBBdXRoZW50aWNhdGlvblRwbVBpbkFuZEtleVVzYWdlIjogImJsb2NrZWQiLAoJCSJyZWNvdmVyeU9wdGlvbnMiOiB7CgkJCSJyZWNvdmVyeVBhc3N3b3JkVXNhZ2UiOiAicmVxdWlyZWQiLAoJCQkicmVjb3ZlcnlLZXlVc2FnZSI6ICJibG9ja2VkIiwKCQkJImhpZGVSZWNvdmVyeU9wdGlvbnMiOiB0cnVlLAoJCQkiZW5hYmxlUmVjb3ZlcnlJbmZvcm1hdGlvblNhdmVUb1N0b3JlIjogdHJ1ZSwKCQkJInJlY292ZXJ5SW5mb3JtYXRpb25Ub1N0b3JlIjogInBhc3N3b3JkT25seSIKCQl9Cgl9LAoJImJpdExvY2tlckZpeGVkRHJpdmVQb2xpY3kiOiB7CgkJInJlY292ZXJ5T3B0aW9ucyI6IHsKCQkJInJlY292ZXJ5UGFzc3dvcmRVc2FnZSI6ICJyZXF1aXJlZCIsCgkJCSJyZWNvdmVyeUtleVVzYWdlIjogImJsb2NrZWQiLAoJCQkiaGlkZVJlY292ZXJ5T3B0aW9ucyI6IHRydWUsCgkJCSJlbmFibGVSZWNvdmVyeUluZm9ybWF0aW9uU2F2ZVRvU3RvcmUiOiB0cnVlLAoJCQkicmVjb3ZlcnlJbmZvcm1hdGlvblRvU3RvcmUiOiAicGFzc3dvcmRPbmx5IgoJCX0KCX0KfQ=="
        }
    ]
}
"@ | convertfrom-json

. ($psscriptroot+"\GraphFunctions-new.ps1")
refreshConnection
cls
write-host "------ BADLOCKER ------" -ForegroundColor Red
write-host
write-host "I've made a bitlocker policy for silent encryption, but the encryption fails. The errors complain about startup authentication conflicts"
write-host "When the user boots, it should go straight to windows - no pins, no keys"
write-host 
write-host
write-host "Hint: https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bitlocker-group-policy-settings#bkmk-unlockpol1"
write-host 
write-host

if((read-host "Enter 'Y' to create profile (Only create it once, otherwise it'll confuse the validator)").toLower() -like "y*"){
    $null = execute-step $steps.entries[0]
    write-host "Device Configuration profile of type Endpoint Protection with name Badlocker created for challenge!" -ForegroundColor Green
}

while (-not (verify-Step $steps.entries[1])){
    read-host "Policy is still incorrect. Press enter to check again"
}

write-host "You did it! Here's the flag:" -ForegroundColor Yellow
write-host ([System.Text.Encoding]::UTF8.getString([convert]::FromBase64String("Y3Rme0JMMENLN0gzQjRETDBDS30="))) -ForegroundColor Green
    