#Requires -modules azuread
import-module azuread
$Tenant = (iex (iwr "https://raw.githubusercontent.com/microsoftgraph/powershell-intune-samples/master/CompanyPortalBranding/CompanyPortal_Get.ps1" -usebasicparsing).content)

write-host "Connected to : " -ForegroundColor Green -NoNewline
write-host ($Tenant.displayName) -ForegroundColor Magenta

$uri = "https://graph.microsoft.com/beta/me"
write-host ("Hello, "+(Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).displayName) -foregroundcolor yellow

$searchTerm = (read-host "search term")

write-host "Pulling device configurations" -ForegroundColor green
$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
$result = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
$result = $result.value #Rinse the output

write-host "Searching for setting" -ForegroundColor yellow
$configResults = ($result | where-object {$_| get-member | where-object membertype -like "NoteProperty"|% -begin {$resultMatch = $false} -process {$resultMatch = $resultmatch -or ($_.name -like $searchTerm )} -end {$resultMatch}})

write-host "Pulling device compliance policies" -ForegroundColor green
$uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies"
$result = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get
$result = $result.value #Rinse the output
write-host "Searching for setting" -ForegroundColor yellow
$complianceResults = ($result | where-object {$_| get-member | where-object membertype -like "NoteProperty"|% -begin {$resultMatch = $false} -process {$resultMatch = $resultmatch -or ($_.name -like $searchTerm )} -end {$resultMatch}})

function display($results){
$results | select id, displayname, "$searchterm" | ft
}

display($configResults)
display($complianceResults)
