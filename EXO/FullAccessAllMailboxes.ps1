#Grants full access to the Permission Target on all mailboxes in EXO

$PermissionTarget = ""
get-mailbox -RecipientTypeDetails usermailbox |% {Add-MailboxPermission -identity $_.identity -user $PermissionTarget -AccessRights fullaccess -InheritanceType all }
