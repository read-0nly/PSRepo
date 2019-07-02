foreach ($a in (Get-Mailbox -ResultSize Unlimited |select PrimarySMTPAddress)) {
  Get-InboxRule -Mailbox $a.PrimarySMTPAddress | ?{
    ($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectTo -ne $null)
  } |
  select MailboxOwnerID,Name,Identity,ForwardTo,ForwardAsAttachmentTo, RedirectTo, DeleteMessage | 
  Export-Csv "C:\InboxRules.csv" -append 
};
echo "`a"
