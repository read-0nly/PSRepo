**Convert Base64 blob to UTF 8 (Stop using suspicious online decoders!)**

```powershell
[System.Text.Encoding]::UTF8.getString([convert]::FromBase64String((read-host "Enter base64 blob")))
```

**Fetch the enrolling user of and enrolled device without talking to AAD/Intune or being in that user's session**
```powershell
(get-itemproperty "hklm:\SOFTWARE\Microsoft\Enrollments\*" | where-object {$_.upn -ne $null}).upn
```
