param(
    $FolderPath
)
$script:workDir = $FolderPath
$EvtLvlColors = @{
    "Information" = "White";
    "Verbose" = "Cyan";
    "Warning" = "Yellow";
    "Error" = "Red";
    "Critical" = "Magenta"
}


function introFetch(){
    introwatermark(-1) 
    $script:workDir  =  (read-host "Please enter the path to the directory containing mdmdiagnosticstool output ('.' is the alias of the current directory)")
}

function introWatermark($i){
    $wmLine  = "------------------------------------------------"
    $wmTitle = "-------:        EVTXRipper  v0.1:        -------"
    $wmState = @(
               "-------:   FETCHING WORKING DIRECTORY:   -------",
               "-------:    INITIALIZING EVENT ARRAY:    -------",
               "-------:       GROUPING  EVENTIDS:       -------",
               "-------:       OUTPUTING  RESULTS:       -------",
               "-------:        SAVING IS CARING:        -------"
               )
    $wmColor =@("Red","Yellow","Green","Cyan", "Magenta")
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
    introWatermark(0)
    $AllEvents = get-winevent -path ($workdir + "\*.evtx")
    introWatermark(1)
    $AllGrouped = ($AllEvents | group id, providername)
    introWatermark(2)
    $AllUniques = $AllGrouped | %{($_.group | sort-object timecreated)[0]}
    $Selection = @("level", "leveldisplayname", "timecreated", "message", "id", "logname", "processid", "machinename", "userid", "containerlog")
    $AllUniques | sort-object timecreated | select-object -property $selection | out-gridview -title "All Unique EventIDs - First Occurence"
    introWatermark(3)
    $AllEventsPath = $null
    write-host
    write-host
    if((read-host "Enter 'Y' to export All Events to csv").ToUpper() -eq "Y"){
        $AllEventsPath = (read-host "Enter path to directory to save file ('.' is the alias of the current directory)")
        #While path is invalid
        while(($AllEventsPath -eq "") -or (-not (test-path $AllEventsPath))){
                $AllEventsPath = read-host "Enter path to directory to save file ('.' is the alias of the current directory)"
        }
        $FileName = (get-date -Format "yymmdd-") + "AllEvents.csv"
        introwatermark(3)
        write-host ("Saving to file [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Yellow"
        $AllEvents | sort-object timecreated | select-object -property $selection | export-csv ($AllEventsPath +"\"+$FileName)
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
        $AllUniques | sort-object timecreated | select-object -property $selection | export-csv ($AllEventsPath +"\"+$FileName)
        write-host ("Saved [ " + $AllEventsPath +"\"+$FileName+" ]") -ForegroundColor "Green"

    }
    else{
        introwatermark(3)
        write-host "You have chosen not to export All Unique Events to a file" -ForegroundColor red
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
