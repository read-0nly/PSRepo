#The CSV file technically only needs one column called name, with the display names of the contacts
#Example:
<#
"Name"
"Contact 1"
"Contact 2"
"Contact 3"
#>
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession
$ContactCSV = import-csv (read-host "Please enter the path to the Contact CSV file")
$DistributionGroup = read-host "Please enter the name of the Distribution Group to add them to"
$ContactCSV | %{ Add-DistributionGroupMember -identity $DistributionGroup -Member $_.Name}
