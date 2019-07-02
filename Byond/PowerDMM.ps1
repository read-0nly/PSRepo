# Define Parameters
#region PARAM
param(
    [Parameter(Mandatory = $true)]$mapPath,
    [Parameter(Mandatory = $true)]$outpath,
	$basecolor=@(200,200,200),
	$TileFilters=$null,
    $mode = "legacy"
)
#endregion PARAM

# May I forever be shamed for this stupid: https://github.com/PowerShell/PowerShell/issues/9584
# Many thanks to vexx32
#region DRAWING IMPORT

if ($PSVersionTable.PSVersion.Major -le 5) {
    Add-Type -AssemblyName System.Drawing
}
else {
    Add-Type -AssemblyName System.Drawing.Common
}
#endregion

# Define common variables
#region VAR DECLARATION
    [System.Collections.Arraylist]$mapArray = new-object System.Collections.arraylist
    [hashtable]$TileHashtable = new-object hashtable; 
    $PartNameList = @()
    [System.Drawing.Bitmap]$image = New-Object system.drawing.bitmap(255,255)
    [hashtable]$AbstractTileShadeHashtable = new-object hashtable
    [hashtable]$AbstractTileColorHashtable = new-object hashtable
#endregion VAR DECLARATION

# This contains the parser, which abstracts the dmm into $tilehashtable and $maparray
#region FILE PARSING
    function parse(){
        #Open the map, and split it at the seam between the glyph definition and glyph map sections
        write-host "Splitting glyph definition from glyph arrays..." -ForegroundColor Red -NoNewline
        $map = get-content $mappath -raw
        $Split = $map.replace("`n`n","|").split("|")
        $TileDefs = $split[0]
        $mapDef = $split[1]
        remove-variable "map"
        write-host "Map Definition Bisected!" -ForegroundColor Red

        #Split the glyph defintion between name and definition, add the pair to the hash table
        #Also add the name of all parts of the definition in a list for filter creation
        write-host "Splitting Glyph label from definition and hashtabling..." -ForegroundColor Yellow -NoNewline
        $TileDefArray = $TileDefs.replace("`n""","|""").split("|")
        remove-variable "tileDefs"
        [System.Collections.ArrayList]$TileDefList = new-object System.Collections.ArrayList; 
        $null=($tileDefArray|%{if(-not ($_.substring(0,2) -eq "//")){$TileHAshtable.Add($_.substring(1,3),([regex]"(\/\w+)+").Matches($_.substring(8, $_.length-8)).value);$TileDefList.add(([regex]"(\/\w+)+").Matches($_.substring(8, $_.length-8)).value)}} -erroraction 'silentlycontinue')
        remove-variable "TileDefArray"
        write-host "Hashtabled!" -ForegroundColor Yellow

        #Pull unique name list from the definition parts
        write-host "Parsing unique name list..." -ForegroundColor Green -NoNewline
        $PartNameList = ($TileDefList|%{([regex]"(\/\w+)+").Matches($_).value})|sort-object -unique
        remove-variable "TileDefList"
        write-host "Name list parsed!" -ForegroundColor Green
    
        #Turn glyph map from string to 2d array for easier addressing
        write-host "Building glyph map array..." -ForegroundColor cyan -nonewline
        $i = 0
        $mapRows = $mapDef.Split("}")
        while($i -lt $mapRows.Count){
            $j=1
            try{$mapCells= $mapRows[$i].split("=")[1].replace('"',"").replace("{","").split("`n")}catch{}
            [System.Collections.ArrayList]$mapArrayRow = new-object System.Collections.arraylist
            while($j -lt $mapCells.Count){
                $null=($mapArrayRow.add($mapCells[$j]))
                $j++                
            }
            $null=($mapArray.add($mapArrayRow))
            $i++
        }
        remove-variable "maprows"
        remove-variable "i"
        write-host "Glyph map array built!" -ForegroundColor cyan
    }
#endregion FILE PARSING

# This is where the horror happens. The nested loops
# put a special kind of hurt on the run time of this thing
#region MAP GENERATORS
    function FilteredMap() {
        write-host "`tGenerating abstracted glyph shade table..." -ForegroundColor magenta -NoNewline
        foreach($tileKey in $TileHashtable.Keys.split("`n")){
            foreach($entry in $TileHashtable[$TileKey]){    
                $i=0
                while($i -lt $TileFilters[0].keys.split("`n").Count){
                    if($entry -like $TileFilters[0].keys.split("`n")[$i]){
                        if($AbstractTileShadeHashtable.ContainsKey($tilekey)){
                            if($AbstractTileShadeHashtable[$tileKey] -lt $tileFilters[0][$tileFilters[0].keys.split("`n")[$i]]){
                                $AbstractTileShadeHashtable[$tileKey] = $tileFilters[0][$tileFilters[0].keys.split("`n")[$i]]
                            }
                        }
                        else{
                            $AbstractTileShadeHashtable.add($TileKey, $tileFilters[0][$tileFilters[0].keys.split("`n")[$i]])
                        }
                    }
                    $i++
                    $i=0
                    while($i -lt $TileFilters[1].keys.split("`n").Count){
                        if($entry -like $TileFilters[1].keys.split("`n")[$i]){
                            if($AbstractTileColorHashtable.ContainsKey($tilekey)){
                                        if([int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][0]) -gt -1)){
                                            $AbstractTileColorHashtable[$tileKey]["R"]=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][0]+$AbstractTileColorHashtable[$tileKey]["R"])*0.5);
                                        }
                                        if([int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][1]) -gt -1)){
                                            $AbstractTileColorHashtable[$tileKey]["G"]=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][1]+$AbstractTileColorHashtable[$tileKey]["G"])*0.5);
                                        }  
                                        if([int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][2]) -gt -1)){
                                            $AbstractTileColorHashtable[$tileKey]["B"]=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][2]+$AbstractTileColorHashtable[$tileKey]["B"])*0.5);
                                        }
                            }
                            else{
                                $AbstractTileColorHashtable.add($TileKey, @{
                                        "R"=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][0]+$basecolor[0])*0.5);
                                        "G"=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][1]+$basecolor[1])*0.5);
                                        "B"=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][2]+$basecolor[2])*0.5);
                                    }
                                )
                            }
                        }
                    $i++
                    }  
                }
            }
        }
        write-host "Abstracted glyph shade table generated!" -ForegroundColor magenta
        write-host "`tBuilding Map..." -ForegroundColor yellow -NoNewline
        $i=0
        while($i -lt $mapArray.Count){
            $j = 0
            while($j -lt $mapArray[$i].count){
                try{
                    $image.SetPixel(
                        $i,$j,
                        [System.Drawing.Color]::FromArgb(
                            [int]($AbstractTileColorHashtable[$mapArray[$i][$j]]["R"]*($AbstractTileShadeHashtable[$mapArray[$i][$j]])),
                            [int]($AbstractTileColorHashtable[$mapArray[$i][$j]]["G"]*($AbstractTileShadeHashtable[$mapArray[$i][$j]])),
                            [int]($AbstractTileColorHashtable[$mapArray[$i][$j]]["B"]*($AbstractTileShadeHashtable[$mapArray[$i][$j]]))
                        )
                    )
                }
                catch{
                #echo ("Error at "+$i+":"+$j)
                }
                $J++
            }
            $i++;
        }
        write-host "Map built!" -ForegroundColor yellow
        write-host "`tsaving file..." -ForegroundColor green -NoNewline
        $image.Save($outpath,[System.Drawing.Imaging.ImageFormat]::Bmp)
        write-host "file saved!" -ForegroundColor green
    }
    function Legacy(){
        write-host "`tGenerating abstracted glyph shade table..." -ForegroundColor yellow -NoNewline
        foreach($tileKey in $TileHashtable.Keys.split("`n")){
            foreach($entry in $TileHashtable[$TileKey]){    
                $i=0
                while($i -lt $TileFilters[0].keys.split("`n").Count){
                    if($entry -like $TileFilters[0].keys.split("`n")[$i]){
                        if($AbstractTileShadeHashtable.ContainsKey($tilekey)){
                            if($AbstractTileShadeHashtable[$tileKey] -lt $tileFilters[0][$tileFilters[0].keys.split("`n")[$i]]){
                                $AbstractTileShadeHashtable[$tileKey] = $tileFilters[0][$tileFilters[0].keys.split("`n")[$i]]
                            }
                        }
                        else{
                            $AbstractTileShadeHashtable.add($TileKey, $tileFilters[0][$tileFilters[0].keys.split("`n")[$i]])
                        }
                    }
                    $i++
                }      

            }
        }
        write-host "`tAbstracted glyph shade table generated!" -ForegroundColor yellow
        write-host "`tGenerating abstracted glyph color table..." -ForegroundColor green -NoNewline
        foreach($tileKey in $TileHashtable.Keys.split("`n")){
            foreach($entry in $TileHashtable[$TileKey]){    
                $i=0
                while($i -lt $TileFilters[1].keys.split("`n").Count){
                    if($entry -like $TileFilters[1].keys.split("`n")[$i]){
                        if($AbstractTileColorHashtable.ContainsKey($tilekey)){
                                    if([int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][0]) -gt -1)){
                                        $AbstractTileColorHashtable[$tileKey]["R"]=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][0]+$AbstractTileColorHashtable[$tileKey]["R"])*0.5);
                                    }
                                    if([int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][1]) -gt -1)){
                                        $AbstractTileColorHashtable[$tileKey]["G"]=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][1]+$AbstractTileColorHashtable[$tileKey]["G"])*0.5);
                                    }  
                                    if([int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][2]) -gt -1)){
                                        $AbstractTileColorHashtable[$tileKey]["B"]=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][2]+$AbstractTileColorHashtable[$tileKey]["B"])*0.5);
                                    }
                        }
                        else{
                            $AbstractTileColorHashtable.add($TileKey, @{
                                    "R"=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][0]+$basecolor[0])*0.5);
                                    "G"=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][1]+$basecolor[1])*0.5);
                                    "B"=[int](($tileFilters[1][$tileFilters[1].keys.split("`n")[$i]][2]+$basecolor[2])*0.5);
                                }
                            )
                        }
                    }
                    $i++
                }      

            }
        }
        write-host "`tAbstracted glyph color table generated!" -ForegroundColor green
        write-host "`tBuilding Map..." -ForegroundColor cyan -NoNewline
        $i=0
        $display = ""
        while($i -lt $mapArray.Count){
            $j = 0
            while($j -lt $mapArray[$i].count){
                try{
                    $image.SetPixel(
                        $i,$j,
                        [System.Drawing.Color]::FromArgb(
                            [int]($AbstractTileColorHashtable[$mapArray[$i][$j]]["R"]*($AbstractTileShadeHashtable[$mapArray[$i][$j]])),
                            [int]($AbstractTileColorHashtable[$mapArray[$i][$j]]["G"]*($AbstractTileShadeHashtable[$mapArray[$i][$j]])),
                            [int]($AbstractTileColorHashtable[$mapArray[$i][$j]]["B"]*($AbstractTileShadeHashtable[$mapArray[$i][$j]]))
                        )
                    )                
                }
                catch{
                #echo ("Error at "+$i+":"+$j)
                }
                $J++
            }
            $display += "`n"
            $i++;
    

        }
        write-host "`tMap built!" -ForegroundColor cyan    
        write-host "`tsaving file..." -ForegroundColor Magenta -NoNewline
        $image.Save($outpath,[System.Drawing.Imaging.ImageFormat]::Bmp)
        write-host "`tfile saved!" -ForegroundColor Magenta

    }
    function ConsoleMap(){

        write-host "Generating ConsoleMap Filtered Glyph List" -ForegroundColor White
        write-host "Creating filter and symbols..." -ForegroundColor Red -NoNewline
        $TileFilters = @("/turf/closed*","/turf/open/floor*","/turf/open/space*")
        $TileRep=@("█","▒"," ")
        write-host "Filter and symbols generated!" -ForegroundColor Red

        write-host "Generating abstracted glyph table..." -ForegroundColor yellow -NoNewline
        [hashtable]$AbstractTileHashtable = new-object hashtable
        foreach($tileKey in $TileHashtable.Keys.split("`n")){
            foreach($entry in $TileHashtable[$TileKey]){    
                $i=0
                while($i -lt $TileFilters.Count){
                    if($entry -like $TileFilters[$i]){
                        if($AbstractTileHashtable[$tileKey] -ne $null){
                            if($AbstractTileHashtable[$tileKey] -gt $i){
                                $AbstractTileHashtable[$tileKey] = $i
                            }
                        }
                        else{
                            $AbstractTileHashtable.add($TileKey, $i)
                        }
                    }
                    $i++
                }      

            }
        }
        write-host "Abstracted glyph table generated!" -ForegroundColor yellow

        write-host "Building Map String..." -ForegroundColor green -NoNewline
        $i=0
        $display = ""
        while($i -lt $mapArray.Count){
            $j = 0
            while($j -lt $mapArray[$i].count){
                try{$display+=$TileRep[$abstractTileHashTable[$mapArray[$i][$j]]]}
                catch{
                }
                $J++
            }
            $display += "`n"
            $i++;
    

        }
        write-host "Map built!" -ForegroundColor green
        write-host "List Generated!" -ForegroundColor White
        $display
    }
#endregion MAP GENERATORS

# This contains the function that calls the different render methods
#region RENDER FUNCTION
function render(){
    if($mode -ieq "filtered"){
        write-host "Generating filtered Bitmap map..." -ForegroundColor White
        . filteredmap
        write-host "Bitmap map Generated!" -ForegroundColor White
    }
    elseif($mode -ieq "legacy"){
        write-host "Generating filtered Bitmap map..." -ForegroundColor White
        . Legacy
        write-host "Bitmap map Generated!" -ForegroundColor White
    }
    elseif($mode -ieq "console"){
        . ConsoleMap
    }
}
#endregion RENDER FUNCTION

# This is the main user interface at the moment, a pseudo-statemachine because I've 
# never made one before so why not
#region FILTER GENERATOR
    function filterBuilder(){    
        $currentState=0
        $currentCommand = "quit"
        $currentCollection=@()
        $rootNode = "^\/\w+"
        $nextNode = "\/\w+"
        $currentFilter=$rootNode
        $Notification=""
        $recurse = 0
        while ($currentState -ge 0){
            switch($currentstate){
                0{           
                    #Handling
                    cls
                    $i=0
                    if($Notification -ne ""){write-host ($notification) -foregroundcolor red;$notification=""}
            
                    if($recurse -eq 0){
                        $currentCollection =  $PartNameList|%{([regex]$currentFilter).Matches($_).value}|sort-object -unique
                    }
                    elseif($recurse -eq 1){
                        $currentCollection =  $PartNameList|%{([regex]($currentFilter+"[A-z\/_\-]+")).Matches($_).value}|sort-object -unique
                    }
                    else{
                        $recurse=0;
                        break;
                    }
           
                    write-host ("Current node = "+$currentfilter.replace("\/\w+","*").replace("\/","/").replace("^",""))
                    $currentCollection|%{write-host (""+$i+": "+$_);$i++}

                    $currentcommand = read-host "Command"
                    $currentState=1           
                }
                1{
                    #Command Router
                    switch(([regex]"\w+").Matches($currentcommand)[0].value){
                
                        "list"{
                            if(($currentcommand.split(" ")[1] -ne "") -and ($currentcommand.split(" ")[1] -ne $null)){
                                try{
                                    $currentfilter=$currentCollection[([int]($currentcommand.split(" ")[1]))] + $nextNode
                                }
                                catch{
                                    if($currentcommand.split(" ")[1] -eq "root"){
                                        $currentFilter=$rootNode
                                    }
                                    elseif($currentcommand.split(" ")[1] -eq "filter"){
                                        $currentState=2
                                        break;
                                    }
                                    else{
                                        $currentfilter = $currentcommand.split(" ")[1].replace("/","\/") + $nextNode
                                    }
                                }
                            }
                            $currentState=0
                        }
                        "recurse"{
                            echo "recurse"
                            $recurse = [int]$currentcommand.split(" ")[1]
                            $currentState=0
                        }
                        "quit"{
                            echo "quit"
                            $currentState=-1
                        }
                        "help"{                
                            cls
                            if($Notification -ne ""){write-host ($notification) -foregroundcolor red;$notification=""} 
                    
                            write-host "=============================================================================================" -foregroundcolor yellow          
                            write-host "Commmands are list, addshade, addcolor, recurse, save, load, render, quit" -foregroundcolor yellow
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "list [int|string] - sets the current node and lists children"
                            write-host "usage examples:"
                            write-host "list 0 - Drill down to the node selected"
                            write-host "list /area - set current node to /area"
                            write-host "list ^ | list root - return to the top level"
                            write-host "list filter - currently set filters and their settings"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "addshade [float] - adds a shade filter between 0-1, 1 being full brightness"
                            write-host "usage examples:"
                            write-host "addshade 0.5 - creates a filter at the current node of 0.5"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "addcolor [int],[int],[int] - adds a color filter with 3 values between -1 and 255"
                            write-host "                             representing the RGB channels. -1 means to not consider"
                            write-host "                             value for averaging, since 0 would dampen the channel."
                            write-host "                             This allows for channel-specific filters"
                            write-host "usage examples:"
                            write-host "addcolor 255,0,-1 - creates a filter that dampens green, boosts red, and doesn't affect blue"
                            write-host "                    at current node"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "recurse [0|1] - list childnodes recursively or not"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "save [string] - saves the current tilefilter set"
                            write-host "usage examples:"
                            write-host "save - saves in current directory as filter.xml"
                            write-host "save xray - saves in current directory as xray.xml"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "load [string] - loades a tilefilter set"
                            write-host "usage exampes:"
                            write-host "load - loads filter.xml from current directory"
                            write-host "load xray - loads xray.xml from current directory"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "render - renders current tilefilter on current map"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host "quit - quit"
                            write-host "=============================================================================================" -foregroundcolor yellow
                            write-host ""
                            write-host ""
                            write-host ""
                            read-host "press enter"
                            $currentState=0
                        }
                        "addshade"{
                            $cleanFilters = $currentFilter.replace($nextnode,"*").replace("\/","/").replace("^","")
                            $TileFilters[0].add($cleanFilters, [double]($currentcommand.split(" ")[1]))
                            $Notification+="shade added"
                            $currentcommand ="list"
                        }
                        "addcolor"{
                            $cleanFilters = $currentFilter.replace($nextnode,"*").replace("\/","/").replace("^","")
                            $colorValues = $currentcommand.split(" ")[1].split(",")
                            $colorArray = @([int]$colorValues[0],[int]$colorValues[1],[int]$colorValues[2])
                            $TileFilters[1].add($cleanFilters, $colorArray)
                            $Notification+="color added"
                            $currentcommand ="list"
                        }
                        "save"{
                            if(($currentcommand.split(" ")[1] -ne $null) -and ($currentcommand.split(" ")[1] -ne "")){
                                $TileFilters | export-Clixml (".\"+($currentcommand.split(" ")[1])+".xml")
                            }
                            else{
                                $TileFilters | export-Clixml ".\filters.xml"
                            }
                            $Notification+="saved"
                            $currentcommand ="list"
                        }
                        "load"{
                            if(($currentcommand.split(" ")[1] -ne $null) -and ($currentcommand.split(" ")[1] -ne "")){
                                $TileFilters = Import-Clixml (".\"+($currentcommand.split(" ")[1])+".xml")
                            }
                            else{
                                $TileFilters = Import-Clixml ".\filters.xml"
                            }
                            $Notification+="loaded"
                            $currentcommand ="list"
                        }
                        "render"{
                            $currentState=3
                        }
                        default{
                            $Notification+="Enter a valid command. Enter 'help' for more info"
                            $currentState=0
                        }
                    }
                }
                2{
                    cls
                    if($Notification -ne ""){write-host ($notification) -foregroundcolor red;$notification=""}
                    write-host "Current filters:"
                    $TileFilters
                    $currentcommand = read-host "Command"
                    $currentState=1           
                }
                3{
                    cls
                    write-host "rendering..."
                    . render
                    $currentState=-1

                }
                -1{
                    write-host "goodbye"
                }
            }
        }
    }
#endregion FILTER GENERATOR

# This is where everything kicks off once it's all defined
#region runtime
if($TileFilters -eq $null){
    . parse
    . filterBuilder
}
elseif($tilefilters.GetType().Name -eq "String"){
    $TileFilters = Import-Clixml $TileFilters   
    . parse
    . render
}
else{
    . parse
    . filterBuilder
}
#endregion runtime

