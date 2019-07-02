$Target = "" #Person who should get Editor
get-mailbox | %{Add-MailboxFolderPermission ($_.PrimarySmtpAddress+":\Calendar") -user $Target -AccessRights Editor -SharingPermissionFlags Delegate}
