#For analysis of multiple evtx files, looks for 0x00000000 error codes then looks for references to that error code in documentation
param(
    $FolderPath
)

#region VAR PREP
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$script:workDir = $FolderPath
$EvtLvlColors = @{
    "Information" = "White";
    "Verbose" = "Cyan";
    "Warning" = "Yellow";
    "Error" = "Red";
    "Critical" = "Magenta"
}
$ErrorCodeRefURLs = @{
	"0x[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" = @( #0x00000000 codes - First scan for all 8, then scan for all 4
		"https://docs.microsoft.com/en-us/intune/enrollment/troubleshoot-windows-enrollment-errors",
		"https://docs.microsoft.com/en-us/windows/deployment/windows-autopilot/known-issues",
		"https://docs.microsoft.com/en-us/sccm/comanage/how-to-monitor",
		"https://docs.microsoft.com/en-us/azure/active-directory/devices/troubleshoot-hybrid-join-windows-current",
		"https://docs.microsoft.com/en-us/intune/fundamentals/troubleshoot-company-resource-access-problems",
		"https://docs.microsoft.com/en-us/windows/win32/mdmreg/mdm-registration-constants",
		"https://docs.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-error-and-success-constants",
		"https://docs.microsoft.com/en-us/windows/deployment/upgrade/upgrade-error-codes",
		"https://docs.microsoft.com/en-us/windows/deployment/update/windows-update-errors",
		"https://docs.microsoft.com/en-us/windows/deployment/update/windows-update-error-reference",
		"https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/705fb797-2175-4a90-b5a3-3918024b10b8",
		"https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55",
		"https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/18d8fbe8-a967-4f1c-ae50-99ca8e491d2d",
		"https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-vds/5102cc53-3143-4268-ba4c-6ea39e999ab4",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--0-499-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--500-999-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1000-1299-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1300-1699-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1700-3999-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--4000-5999-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--6000-8199-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--8200-8999-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--9000-11999-",
		"https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--12000-15999-",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-1",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-2",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-3",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-4",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-5",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-6",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-7",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-8",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-9",
		"https://docs.microsoft.com/en-us/windows/win32/com/com-error-codes-10",
		"https://docs.microsoft.com/en-us/windows/win32/seccrypto/common-hresult-values"
	);
	"AADSTS[0-9]+" = @( #AADSTS codes
		"https://docs.microsoft.com/en-us/azure/active-directory/develop/reference-aadsts-error-codes",
		"https://docs.microsoft.com/en-us/azure/active-directory/reports-monitoring/reference-sign-ins-error-codes"
	)
}
$URLCache=@{}
$ErrorCodeRefURLs.keys.split("`r`n") | %{$ErrorCodeRefURLs[$_] | %{$URLCache.add($_,(Invoke-WebRequest $_).content)}}

#endregion VAR PREP

function introFetch(){
    introwatermark(-1) 
    $script:workDir  =  (read-host "Please enter the path to the directory containing mdmdiagnosticstool output ('.' is the alias of the current directory)")
}

function introWatermark($i){
    <#
    V0.1
        Created base script that pulls all events and returns unique per ID
    V0.2
        Created Error Code extractor
    V0.3
        Autodocs pull
    V0.4
        ETL Handling
    TODO: 
        - Create errorcode CSV to allow vlookup
        - Parse Autopilot JSON
        - Review and flag inconsistencies in mdmdiagereport
        - Review TPMHLInfo file
        - Extend the error code logic (
            for instance: 
                recognizing decimal errors? 
                Better heuristics so it stops grabbing timestamps? 
                Full array of found errors for ID?
            )
    WISHLIST:
        - Extract all URLs from Bits
        - Extract IME Script payloads
    #>
    $wmLine  = "------------------------------------------------"
    $wmTitle = "-------:        EVTXRipper  v0.4:        -------"
    $wmState = @(
               "-------:   FETCHING WORKING DIRECTORY:   -------",
               "-------:    INITIALIZING EVENT ARRAY:    -------",
               "-------:       GROUPING EVENT IDS:       -------",
               "-------:     GATHERING  ERROR CODES:     -------",
               "-------:       OUTPUTING  RESULTS:       -------",
               "-------:        SAVING IS CARING:        -------"
               )
    $wmColor =@("Red","Yellow","Green","Cyan", "Magenta", "White")
    cls
    start-sleep -Milliseconds 5
    write-host $wmLine -ForegroundColor white
    $splitState = $wmTitle.split(":")
    $curColor = $wmColor[$i+1]
    $Middle = (" "+$splitState[1]+" ")
    write-host $splitState[0] -ForegroundColor white -NoNewline
    start-sleep -Milliseconds 5
    write-host $Middle -ForegroundColor $curColor -NoNewline
    start-sleep -Milliseconds 5
    write-host $splitState[2] -ForegroundColor white
    $splitState = $wmState[$i+1].split(":")
    $curColor = $wmColor[$i+1]
    $Middle = (" "+$splitState[1]+" ")
    write-host $splitState[0] -ForegroundColor white -NoNewline
    start-sleep -Milliseconds 5
    write-host $Middle -ForegroundColor $curColor -NoNewline
    start-sleep -Milliseconds 5
    write-host $splitState[2] -ForegroundColor white
    write-host $wmLine -ForegroundColor white
    write-host
    write-host
    start-sleep -Milliseconds 5

    
}

function runEvtxRipper(){
    #Load all events from evtx files
    introWatermark(0)
    $script:AllEvents = new-object System.Collections.ArrayList
    write-host "Fetching file list..." -NoNewline
    $evtFiles = (dir @("*.evtx","*.etl"))
    $evtN = 0
    write-host ("Finished Fetching! Found " + $evtFiles.count + " files")
    write-host
    write-host ("Loading Files")
    write-host ("|"+(('_')*$evtFiles.count)+"|")
    write-host "|" -NoNewline
    $script:AllEvents.addrange((
        $evtFiles | %{
            get-winevent -path ($_.fullname) -oldest
            write-host "█" -ForegroundColor Green -NoNewline
        }))    
    #Group all events by ID and provider
    introWatermark(1)
    $script:AllGrouped = ($AllEvents | group id, providername)  
    $script:AllUniques = $script:AllGrouped | %{($_.group | sort-object timecreated)[0]}
   
    #GetErrorCodes
    introWatermark(2)
    $script:allerrorcodes = @{}
    $script:AllUniques | %{$matches = $null; $_.message -match $ErrorCodeRefURLs.keys.split("`r`n")[0] >> $null; if($allErrorCodes.keys -contains $_){}else{if($matches.count -gt 0){$script:allErrorCodes.add($_, ([string]$matches.values))}}}
    $script:AllUniques | %{$matches = $null; $_.message -match $ErrorCodeRefURLs.keys.split("`r`n")[1] >> $null; if($allErrorCodes.keys -contains $_){}else{if($matches.count -gt 0){$script:allErrorCodes.add($_, ([string]$matches.values))}}}
    introWatermark(3)
   $Selection = @("leveldisplayname", "id", "timecreated", "errorcode", "message", "level", "logname", "processid", "machinename", "userid", "containerlog")
    $Script:UniquesWithError = $script:AllUniques | %{[pscustomobject]@{
        "level"=$_.level;
        "leveldisplayname"=$_.leveldisplayname;
        "timecreated"=$_.timecreated;
        "message"=$_.message;
        "id"=$_.id;
        "logname"=$_.logname;
        "processid"=$_.processid;
        "machinename"=$_.machinename;
        "userid"=$_.userid;
        "containerlog"=$_.containerlog;
        "errorcode"=$AllErrorCodes[$_]
        }} 
    $Script:UniquesWithError | sort-object timecreated| select-object -Property $Selection| out-gridview -title "All Unique EventIDs - First Occurence"
    introWatermark(4)
    $AllEventsPath = $null
    write-host
    write-host 
    $FoundSources = ($urlcache.keys.split("`r`n") | %{$curURL = $_; $allerrorcodes.values | select-object -unique | %{if($urlcache[$curURL] -match $_){echo (""+$_+" found on "+$cururl)}else{}};})

    if((read-host "Enter 'Y' to export All Events to csv").ToUpper() -eq "Y"){
        $AllEventsPath = (read-host "Enter path to directory to save file ('.' is the alias of the current directory)")
        #While path is invalid
        while(($AllEventsPath -eq "") -or (-not (test-path $AllEventsPath))){
                $AllEventsPath = read-host "Enter path to directory to save file ('.' is the alias of the current directory)"
        }
        $FileName = (get-date -Format "yymmdd-") + "AllEvents.csv"
        introwatermark(3)
        write-host ("Saving to file [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Yellow"
        $script:AllEvents | sort-object timecreated | select-object -property $selection | export-csv ($AllEventsPath +"\"+$FileName)
        write-host ("Saved [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Green"

    }
    else{
        introwatermark(3)
        write-host "You have chosen not to export All Events to a file" -ForegroundColor red
        write-host
    }

    $AllEventsPath = $null
    if((read-host "Enter 'Y' to export All Unique Events to csv").ToUpper() -eq "Y"){
        $AllEventsPath = (read-host "Enter path to directory to save file ('.' is the alias of the current directory)")
        while(
            (-not (test-path $AllEventsPath)) -and
            ( -not ($AllEventsPath -eq ""))){
                $AllEventsPath = read-host "Enter path to directory to save file ('.' is the alias of the current directory)"
        }
        $FileName = (get-date -Format "yymmdd-") + "AllUniqueEvents.csv"
        introwatermark(3)
        write-host ("Saving to file [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Yellow"
        $Script:UniquesWithError | sort-object timecreated | select-object -property $selection | export-csv ($AllEventsPath +"\"+$FileName)
        write-host ("Saved [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Green"

    }
    else{
        introwatermark(3)
        write-host "You have chosen not to export All Unique Events to a file" -ForegroundColor red
    }

    $AllEventsPath = $null
    if((read-host "Enter 'Y' to export Unique Error Codes to csv").ToUpper() -eq "Y"){
        $AllEventsPath = (read-host "Enter path to directory to save file ('.' is the alias of the current directory)")
        while(
            (-not (test-path $AllEventsPath)) -and
            ( -not ($AllEventsPath -eq ""))){
                $AllEventsPath = read-host "Enter path to directory to save file ('.' is the alias of the current directory)"
        }
        $FileName = (get-date -Format "yymmdd-") + "UniqueErrorCodes.txt"
        introwatermark(3)
        write-host ("Saving to file [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Yellow"
        $script:AllErrorCodes.values | select-object -unique | out-file ($AllEventsPath +"\"+$FileName)
        write-host ("Saved [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Green"

    }
    else{
        introwatermark(3)
        write-host "You have chosen not to export All Unique Errors to a file" -ForegroundColor red
    }
    $AllEventsPath = $null    
    if((read-host "Enter 'Y' to export Error Code Lookup to file").ToUpper() -eq "Y"){
        $AllEventsPath = (read-host "Enter path to directory to save file ('.' is the alias of the current directory)")
        while(
            (-not (test-path $AllEventsPath)) -and
            ( -not ($AllEventsPath -eq ""))){
                $AllEventsPath = read-host "Enter path to directory to save file ('.' is the alias of the current directory)"
        }
        $FileName = (get-date -Format "yymmdd-") + "ErrorLookup.txt"
        introwatermark(3)
        write-host ("Saving to file [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Yellow"
        $FoundSources | out-file ($AllEventsPath +"\"+$FileName)
        write-host ("Saved [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Green"

    }
    else{
        introwatermark(3)
        write-host "You have chosen not to export All Unique Errors to a file" -ForegroundColor red
    }

}

while(($script:workDir -eq $null)){
    introfetch    
    if(-not ($script:workDir -eq $null)){
        while (-not (test-path $script:workDir) -or (-not ((dir ($script:workDir+'\*.evtx')).count -gt 0))){
            introFetch
        }
    }
}

runEvtxRipper


#-Credential ([System.Security.Principal.WindowsPrincipal]::Current).Identity.Claims.Current)
