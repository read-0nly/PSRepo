$trusteeList = @("email1@contoso.onmicrosoft.com","email2@contoso.onmicrosoft.com","email3@contoso.onmicrosoft.com")
foreach($trustee in $trusteeList){
get-mailbox | %{Add-RecipientPermission ($_.PrimarySmtpAddress) -AccessRights SendAs -Trustee $trustee}
}
 
