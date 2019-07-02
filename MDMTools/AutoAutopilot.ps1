function Configure-Prerequisites{
    # Confirm Powershell updated enough to run this
    $allSet =[bool]([int]((host).version.Major) -ge 5)
    if($allSet){
        #If the version is good, verify state of necessary modules. If any are missing, install them, then import it all. 
        #If any fail, return False, otherwise True to confirm the environment is ready to proceed

        #Check if Azure AD is installed. If it isn't, install. Import it. If the install fails, return false
        if(get-module -listavailable -name "AzureAD*"){
            Write-Host "AzureAD installed" -ForegroundColor Green
            get-module -listavailable -name "AzureAD*" | %{import-module $_}
        } 
        else {
            Write-Host "AzureAD not installed" -ForegroundColor Red
            try{
                install-module AzureAD -force
                get-module -listavailable -name "AzureAD*" | %{import-module $_}
                Write-Host "AzureAD installed" -ForegroundColor Green
            }
            catch{            
                Write-Host "AzureAD cannot be installed - Are you running as Admin?" -ForegroundColor Red            
                $allSet = $false;
            }
        }

        #Check if MS Online is installed. If it isn't, install. Import it. If the install fails, return false
        if(get-module -listavailable -name "MSOnline"){
            Write-Host "MSOnline installed" -ForegroundColor Green
            import-module MSOnline
        } 
        else {
            Write-Host "MSOnline not installed" -ForegroundColor Red
            try{
                install-module MSOnline -force
                import-module MSOnline
                Write-Host "MSOnline installed" -ForegroundColor Green
            }
            catch{            
                Write-Host "MSOnline cannot be installed - Are you running as Admin?" -ForegroundColor Red         
                $allSet = $false;
            }

        }
        

        #Check if the Windows Autopilot Intune module is installed. If it isn't, install. Import it. If the install fails, return false
        if(get-module -listavailable -name "WindowsAutoPilotIntune"){
            Write-Host "WindowsAutoPilotIntune installed" -ForegroundColor Green
            import-module WindowsAutoPilotIntune
        } 
        else {
            Write-Host "WindowsAutoPilotIntune not installed" -ForegroundColor Red
            try{
                install-module WindowsAutoPilotIntune -force
                import-module WindowsAutoPilotIntune
                Write-Host "WindowsAutoPilotIntune installed" -ForegroundColor Green
            }
            catch{            
                Write-Host "WindowsAutoPilotIntune cannot be installed - Are you running as Admin?" -ForegroundColor Red         
                $allSet = $false;
            }
        }
        

        #Check if the script for autopilot CSV generation is installed. If it isn't, install it. If the install fails, return false
        if((get-installedscript | where-object {$_.name -eq "Get-WindowsAutoPilotInfo"})){
            Write-Host "Get-WindowsAutoPilotInfo installed" -ForegroundColor Green
        } 
        else {
            Write-Host "Get-WindowsAutoPilotInfo not installed" -ForegroundColor Red
                try{
                    install-script -name Get-WindowsAutoPilotInfo -force
                    Write-Host "Get-WindowsAutoPilotInfo installed" -ForegroundColor Green
                }
                catch{            
                Write-Host "Get-WindowsAutoPilotInfo cannot be installed - Are you running as Admin?" -ForegroundColor Red         
                $allSet = $false;
            }
        }
        return $allSet
    }
    else{
        #If powershell is outdated, launch page to download 5.1, and return False
        Write-Host "Please update to at least WMF 5.1 to proceed" -ForegroundColor Red -BackgroundColor Black
        start "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
        return $allSet
    }
}

function Connect-Services{
    param(
    $creds = (get-credential)
    )
    #Connect services
    Connect-MsolService -credential $creds
    Connect-AzureAD -credential $creds
    connect-autopilotintune -user $creds.UserName
}

function Add-AutopilotDevice{
    param(
        $folderPath = (read-host "Please enter the path to a RW-accessible folder"),
        $userUPN = (read-host "Please enter the UPN of the owner of the new device"),
        $autopilotGroupName = (read-host "Please enter the name of the AzureAD group targeted by the autopilot profile")
    )
    #Wrap the whole thing in a try block so the moment it fails it all fails, to prevent doing ops on non-existent values.
    try{
        #Generate filename
        $autopilotFile = ($folderPath+"\"+(hostname)+".csv")
        write-host ("Generated filepath:"+$autopilotfile) -ForegroundColor Magenta

        #Generate HWID file, then load device serial number
        get-windowsautopilotinfo.ps1 -outputfile $autopilotFile
        $devSerial = (import-csv $autopilotFile).'Device Serial Number'
        write-host ("Device Serial Number:"+$devSerial) -ForegroundColor Magenta
        
        #Reconnect to assure connection hasn't timed out
        connect-autopilotintune    
        
        #Import the file, reconnect afterwards because this op is long
        write-host ("Beginning import") -ForegroundColor Magenta
        (import-autopilotcsv -csvfile $autopilotFile) > out-null
        connect-autopilotintune
        
        #Invoke resync of autopilot devices to populate the newly imported device
        write-host ("Imported, syncing") -ForegroundColor Green
        invoke-autopilotsync
        
        #Keep trying to pull the new device's details until they're available, then proceed
        write-host "Sleeping until sync done" -ForegroundColor Gray
        do{
            $devID = (get-autopilotdevice | where-object {$_.serialNumber -ieq $devSerial}).id
        }while($devID -eq $null)
        write-host ("Fetched device:"+$devID) -ForegroundColor Magenta

        #Fetch targeted new owner
        $user = get-msoluser -UserPrincipalName $userUPN        
        write-host ("Fetched user:"+$user.displayname) -ForegroundColor Magenta

        #If an owner was found, continue. Otherwise Fail
        if($user -ne $null){
            set-autopilotdeviceassigneduser -displayname $user.displayname -id $devid -userprincipalname $userUPN        
            write-host ("User '"+$user.displayname+"' added to autopilot device '"+$devID+"'") -ForegroundColor Green

            $AADDevice = (get-azureaddevice | where-object {$_.devicephysicalids -ilike ("*ZTDID??"+$devid+"*")})        
            write-host ("Fetched device AAD reference:"+$AADDevice) -ForegroundColor Magenta

            $autopilotGroup = (get-azureadgroup | Where-Object {$_.displayname -ieq $autopilotGroupName})        
            write-host ("Fetched group:"+$autopilotGroup.displayname) -ForegroundColor Magenta

            #If a group was found, continue. Otherwise Fail
            if($autopilotGroup -ne $null){
                Add-azureadgroupmember -objectid $autopilotGroup.objectid -RefObjectId $aaddevice.objectid        
                write-host ("Added device to autopilot group") -ForegroundColor Green

                invoke-autopilotsync        
                write-host ("Device primed, and sync initiated.") -ForegroundColor Green

                write-host ("Sleeping 30 minutes for propagation. Sleep started at "+(date)) -ForegroundColor Gray        
                start-sleep (30*60)

                #Ask if ready for sysprep
                if((read-host "Sysprep? Y/N") -ieq "Y"){
                    C:\windows\System32\sysprep\sysprep.exe -oobe -reboot
                    write-host ("Sysprep initated.") -ForegroundColor Green
                }
                else{
                    write-host ("Sysprep skipped. Please reset windows when you're ready to enroll") -ForegroundColor Yellow
                }
            }
            else{
                write-host ("Autopilot group not found: "+$autopilotGroupName) -foregroundcolor red
            }
        }
        else{
            write-host ("User not found: "+$userUPN) -foregroundcolor red
        }
    }
    catch{
        write-host ("Device priming failed. Please review values supplied and try again.") -ForegroundColor Red
    }
}

function auto-autopilot{    
    param(
        $creds = (get-credential),
        $folderPath = (read-host "Please enter the path to a RW-accessible folder"),
        $userUPN = (read-host "Please enter the UPN of the owner of the new device"),
        $autopilotGroupName = (read-host "Please enter the name of the AzureAD group targeted by the autopilot profile")
    )
    write-host "Checking Prerequisites" -ForegroundColor Magenta
    if(Configure-Prerequisites){
        Connect-Services -creds $creds
        Add-AutopilotDevice -folderpath $folderpath -userupn $userUPN -autopilotGroupName $autopilotGroupName
        write-host ("Finished") -ForegroundColor Green
    }
    else{        
        write-host ("Prerequisite check failed. Please assure WMF 5.1, reboot after installation, and run powershell as Admin") -ForegroundColor Red
    }


}
