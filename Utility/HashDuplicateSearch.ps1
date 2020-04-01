#Hardcoded params are bad, I know
$global:CurrentHashtable = @{}

$global:CurrentResulttable = @{}

$global:loadedPage = @{}

$pageSize = 1000
$global:currentPage = 1
$global:hashLocation = (read-host "Enter the path to the folder for the hash results")
$global:ConsolidatedUnique = @{}
$global:root = (read-host "Enter the path to the folder to search recursively")

$global:ConsolidatedDuplicate = @{}
$global:CurrentResulttable = @{}

 
#region Build Index functions
    #Step Functions
    function GetAllHashesAtLocation(){
        param(
            $CurrentFolder
        )
    
        $files = dir $currentFolder | where-object {-not ($_.mode -like "d*")}

        PutHashesInTable ($files | %{$hash = get-filehash $_.fullname; return $hash}
 )
        $folders = dir $currentFolder | where-object {($_.mode -like "d*")}


        foreach($folder in $folders){
            GetAllHashesAtLocation $folder.fullname
        }

    }

    function PutHashesInTable(){
        param(
            $fileHashes
        )
        foreach ($hash in $fileHashes){
            if([bool]($CurrentHashtable[$hash.hash])){
                $global:CurrentHashtable[$hash.hash].add($hash)
            }

            else{
                $global:CurrentHashtable.add($hash.hash, [System.Collections.ArrayList]@($hash))
            }

            if(($global:CurrentHashtable.values|%{$start += $_.count} -Begin {$start = 0} -end {$start}) -gt $pageSize){
                SaveHashesAndFlush
            }

        }

    }

    function SaveHashesAndFlush(){
		write-host ("Writing page to" +$global:hashLocation + "Hashtable-"+ $global:currentPage+".json" )
        ($global:CurrentHashtable | convertto-json) | out-file ($global:hashLocation + "Hashtable-"+ $global:currentPage+".json")
        $global:currentPage++        
        $global:CurrentHashtable = @{}

    }

    #Primary flow
    function BuildHashIndex(){
        param(
        )
        GetAllHashesAtLocation $global:root 
        SaveHashesAndFlush
    }

#endregion

#region Index Query and Delete
    function QueryDuplicateFromFiles(){
        param(
            $QueryHash
        )
        $global:CurrentResulttable = @{}

        foreach($file in (dir $global:hashLocation)){
            $FileCat = cat $file.fullname
            if($filecat -like (*+$QueryHash+*)){
                $FileContentObject = ($FileCat| ConvertFrom-Json )
                ($FileContentObject.psobject.properties | select-object *) | %{
                    if($_.name -eq $QueryHash){
                        if($global:CurrentResulttable[$file.fullname]){
                            $global:CurrentResulttable[$file.fullname]+=[System.Collections.ArrayList]$_.value
                        }

                        else{
                            $global:CurrentResulttable[$file.fullname] = [System.Collections.ArrayList]@($_.value)
                        }

                    }

                }

            }

        }

    }

    function QueryPageFromFiles(){
        param(
            $QueryPage
        )

        foreach($file in (dir $global:hashLocation)){
            if((test-path $file.FullName)){
                $FileCat = cat $file.fullname
                $foundInFile = $false
                $QueryPage | %{$foundInFile = $foundInFile -or ($filecat -like ("*"+$_+"*"))}

                if($foundInFile){
                    $FileContentObject = ($FileCat| ConvertFrom-Json )
                    ($FileContentObject.psobject.properties | select-object *) | %{
                    #Breaks for # 4? No hash. Maybe because array vs not array?

                        foreach($queryHash in $queryPage){
                            if($_.name -eq $QueryHash){
                            
                                $foundValue = [object]$null
                                if($_.value.hash.count -gt 1){
                                    $foundValue = [System.Collections.ArrayList]$_.value
                                }

                                else{
                                    $foundValue = [System.Collections.ArrayList]@($_)
                                }


                                if($global:CurrentResulttable[$QueryHash]){
                                    $global:CurrentResulttable[$QueryHash].add(@{"hashes"=[System.Collections.ArrayList]$foundValue;"page"=$file.fullname})
                                }

                                else{
                                    $global:CurrentResulttable[$QueryHash] = [System.Collections.ArrayList]@(@{"hashes"=[System.Collections.ArrayList]$foundValue;"page"=$file.fullname})
                                }

                            }

                        }

                    }

                }
            }

        }

    }

    function RemoveDuplicateFromFile(){
        param(
            $duplicateHashObj,
            $filePath
        )
        $FileContentObject = (cat $filePath| ConvertFrom-Json )
        $newFile = @{}

        ($FileContentObject.psobject.properties | select-object *) | %{
            $add = $true
            foreach($entry in $_.value){
                $duplicateHashObj | %{if($entry.path -eq $_.path){
                    $add = $false
                }}

            }

            if($add){
                if($newFile[$_.name]){
                    $newFile[$_.name].add($_.value)
                }

                else{
                    $newFile[$_.name] = [System.Collections.ArrayList]@($_.value)
                }

            }

        }

        $newfile | convertto-json | Out-File $filePath -force
    }

    function loadPage(){
        param(
            $FilePath
        )
        $FileCat = cat $FilePath
        if($filecat -like ("*"+$QueryHash+"*")){
            $FileContentObject = ($FileCat| ConvertFrom-Json )
            ($FileContentObject.psobject.properties | select-object *) | %{
                    if($global:loadedPage[$_.name]){
                        $global:loadedPage[$_.name].add($_.value)
                    }

                    else{
                        $global:loadedPage[$_.name] = [System.Collections.ArrayList]@($_.value)
                    }

                    
            }

        }

    }

#endregion

#region ConsolidateDuplicates
    function backupIndex(){
        $newPath = $global:hashLocation + "\..\backup\"
        if(-not(test-path $newPath)){
            mkdir $newPath
        }

        $allFiles = dir $global:hashLocation
        $allFiles | %{copy-item $_.FullName ($newpath + $_.name)}

    }

    function consolidateHashes(){
        $global:ConsolidatedDuplicate = @{}

        $global:ConsolidatedUnique = @{}

        backupIndex
        $allFiles = dir $global:hashLocation
        $newPath = $global:hashLocation + "\..\consolidated\"
        if(-not(test-path $newPath)){
            mkdir $newPath
        }

        foreach($file in $allFiles){
            $Error.clear()
            $Global:CurrentResulttable = @{}
            loadpage $file.FullName
            $workingHashes = $global:loadedPage.keys.split("`n")
            QueryPageFromFiles $workingHashes
            $global:currentUniques = @{}
            ($Global:CurrentResulttable.keys.split("`n") | where-object {-not ($Global:CurrentResulttable[$_].count -gt 1)} | %{$global:currentUniques += @{$_=$Global:CurrentResulttable[$_]}})
            $global:currentDuplicates =@{}
            ($Global:CurrentResulttable.keys.split("`n") | where-object { ($Global:CurrentResulttable[$_].count -gt 1)} | %{$global:currentDuplicates += @{$_=$Global:CurrentResulttable[$_]}})
            $global:currentPage = 1
            $global:ConsolidatedDuplicate = @{}
            cls
            $keys = $global:currentUniques.keys.split("`n");
            foreach($key in $keys){
                if($global:currentUniques[$key].hashes.count -gt 1){
                    $global:currentUniques[$key]|%{
                        write-host $_.page -ForegroundColor Yellow
                        $_.hashes | %{
                            $a = $_.Hash
                            $b = $_.Path
                            $c = $b.replace($global:root,"")
                            write-host ($a+" | "+$c)
                            if($global:ConsolidatedDuplicate.Keys.count -gt 0){
                                if($global:ConsolidatedDuplicate.Keys.split("`n").count -gt 1000){
                                    SaveHashesAndFlushDuplicateTable
                                }
                            }
                            if($global:ConsolidatedDuplicate[$a]){
                                $global:ConsolidatedDuplicate[$a].add($_)
                            }
                            else{
                            
                                if(($_).GetType().Name -eq "PSCustomObject"){
                                    $global:ConsolidatedDuplicate.add($a,[System.Collections.ArrayList]@($_))
                                }
                                else{
                                    $global:ConsolidatedDuplicate.add($a,$_)
                                }
                            }
                        }
                    }
                    write-host "##################################################################################################################" -ForegroundColor magenta
                }
            }
             
            cls           
            
            $global:PageDeleteTargets = @{}
            $keys = $global:currentDuplicates.keys.split("`n");
            foreach($key in $keys){
                if($global:currentDuplicates[$key].hashes.value.count -gt 1){
                    $global:currentDuplicates[$key]|%{
                        write-host $_.page -ForegroundColor Yellow
                        if($global:PageDeleteTargets[$_.page]){
                            $global:PageDeleteTargets[$_.page].add($key)
                        }
                        else{
                            
                            $global:PageDeleteTargets.add($_.page,[System.Collections.ArrayList]@($key))
                        }
                        $_.hashes.value | %{
                            $a = $_.Hash
                            $b = $_.Path
                            $c = $b.replace($global:root,"")
                            write-host ($a+" | "+$c)
                            if($global:ConsolidatedDuplicate.Keys.split("`n").count -gt 1000){
                                SaveHashesAndFlushDuplicateTable
                            }
                            if($global:ConsolidatedDuplicate[$a]){
                                $global:ConsolidatedDuplicate[$a].add($_)
                            }
                            else{
                            
                                if(($_).GetType().Name -eq "PSCustomObject"){
                                    $global:ConsolidatedDuplicate.add($a,[System.Collections.ArrayList]@($_))
                                }
                                else{
                                    $global:ConsolidatedDuplicate.add($a,$_)
                                }
                            }
                        }
                    }
                    write-host "##################################################################################################################" -ForegroundColor magenta
                }
            }
            #$Global:CurrentResulttable.keys.split("`n") | where-object {$Global:CurrentResulttable[$_].count -gt 1} | %{$Global:CurrentResulttable[$_]; write-host ""} | %{$_.hashes.value}
            
            $targetKeys = [System.Collections.ArrayList]($global:PageDeleteTargets.keys.split("`n"))
            $targetKeys.remove($file.FullName)
            $targetKeys | %{
                RemoveDuplicateFromFile $global:PageDeleteTargets[$_] $_
            }


            
            cls
            write-host
            if(($error).count -gt 0){
                write-host ("Errors this page:"+($Error).count) -ForegroundColor Red
                if(-not (test-path ($global:hashLocation+"\..\backupHash\"))){
                    mkdir ($global:hashLocation+"\..\backupHash")
                }
                move-item $file.FullName ($global:hashLocation+"\..\backupHash\"+$file.Name)
            }
            else{
                write-host ("Errors this page:"+($Error).count) -ForegroundColor Green
                remove-item $file.FullName
                while((test-path $file.FullName)){
                    write-host "Waiting for deletion" -ForegroundColor Yellow
                    start-sleep -Milliseconds 100
                }
            }
            SaveHashesAndFlushDuplicateTable
            write-host
        }


        #SaveHashesAndFlushUniqueTable
    }
    
    function SaveHashesAndFlushUniqueTable(){
        $newPath = $global:hashLocation + "\..\consolidated\"
        if(-not(test-path $newPath)){
            mkdir $newPath
        }

		write-host ("Writing page to" +$global:hashLocation + "HashtableUnique-"+ $global:currentPage+".json" )
        ($global:ConsolidatedUnique | convertto-json) | out-file ($newPath + "HashtableUnique-"+ $global:currentPage+".json")
        $global:currentPage++        
        $global:ConsolidatedUnique = @{}

    }

    function SaveHashesAndFlushDuplicateTable(){
        $newPath = $global:hashLocation + "\..\consolidated\"
        if(-not(test-path $newPath)){
            mkdir $newPath
        }

		write-host ("Writing page to "+$newPath + "HashtableDuplicate-"+ (get-date).ticks+".json" )
        ($global:ConsolidatedDuplicate | convertto-json) | out-file ($newPath + "HashtableDuplicate-"+  (get-date).ticks+".json")
        $global:currentPage++        
        $global:ConsolidatedDuplicate = @{}

    }
#endRegion


#region Console Menu
function drawScreen(){

}

function MenuLoop(){
    
}

#endregion