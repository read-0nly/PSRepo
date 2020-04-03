#Cheap token generation, uses the intune samples scripts to generate the token then uses it to query /me. Returned token is AuthToken

$Tenant = (iex (iwr "https://raw.githubusercontent.com/microsoftgraph/powershell-intune-samples/master/CompanyPortalBranding/CompanyPortal_Get.ps1" -usebasicparsing).content)

write-host "Connected to : " -ForegroundColor Green -NoNewline
write-host ($Tenant.displayName) -ForegroundColor Magenta

$uri = "https://graph.microsoft.com/beta/me"
write-host ("Hello, "+(Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).displayName) -foregroundcolor yellow
