$global:menu = [pscustomobject]@{
    "MenuState" = 1
    "Settings" = @{
        "Vertical" = $false;
        "Width"=30;
        "Spacer" = "|";
        "SelectionRange" = @(-1,0,1);
        "SelectionColors" = @("DarkRed","DarkGray","DarkGreen")
        "SelectionColorcodes" = @(([char]27+"[0m"),([char]27+"[101m"),([char]27+"[100m"),([char]27+"[42m"))
        "ColorMiddle" = 2
    };
    "Cursor" = 1;
    "Items" = @(
        [pscustomobject]@{
            "Name" = "Entry1";
            "Command" = [scriptBlock]{echo "Entry 1"};
            "Selected" = 0
            "Selectable" = 0
        },    
        [pscustomobject]@{
            "Name" = "Entry2";
            "Command" = [scriptBlock]{echo "Entry 2"};
            "Selected" = 0
            "Selectable" = 0
        },    
        [pscustomobject]@{
            "Name" = "Entry3";
            "Command" = [scriptBlock]{echo "Entry 3"};
            "Selected" = 0
            "Selectable" = 1
        }
    )
}

$currentMenu = [ref]$global:Menu

function padString($entry, $width){   
    $string = ""   
    $string = (&{if($entry.Name -eq $Menu.Items[$menu.Cursor].name){"> "}else{""}})+$entry.name+(&{if($entry.Name -eq $Menu.Items[$menu.Cursor].name){" <"}else{""}})
    $pad = $menu.Settings["Width"] - $string.length
    $string = $string.PadLeft([int]($pad/2)+$string.length)
    $string = $string.PadRight($width)
    $string = $menu.settings["selectionColorCodes"][$menu.settings["ColorMiddle"] + $entry.selected] + $string + $menu.settings["selectionColorCodes"][$menu.settings["ColorMiddle"]]
    return $string
}

function paintMenu($curMenu){
    if($curMenu.Settings["Vertical"]){
        $curMenu.Items | %{ 
            write-host $curMenu.Settings["Spacer"] -backgroundcolor $curMenu.settings["SelectionColors"][$curMenu.settings["SelectionRange"].indexof(0)] -nonewline           
            write-host ((padString $_ $curMenu.Settings["Width"])) -backgroundcolor $curMenu.settings["SelectionColors"][$curMenu.settings["SelectionRange"].indexof($_.selected)] -nonewline
            write-host $curMenu.Settings["Spacer"] -backgroundcolor $curMenu.settings["SelectionColors"][$curMenu.settings["SelectionRange"].indexof(0)]
        }
    }
    else{
        $out = $menu.settings["selectionColorCodes"][$menu.settings["ColorMiddle"]]  + $curMenu.Settings["Spacer"] + ($curMenu.Items | %{
            ((padString $_ $curMenu.Settings["Width"])) +
            $curMenu.Settings["Spacer"]})+$menu.settings["selectionColorCodes"][0] 
        cls;    
        $out
        echo ""
    }
    echo "";
}

function paintScreen(){
    paintMenu $currentMenu.Value

}

function menuStep(){
    if($psISE -eq $null){
        switch -wildcard ([system.console]::readkey().Key){
            "UpArrow" {
                if($menu.cursor -gt 0){
                    $Menu.Cursor--
                }
            }
            "LeftArrow" {
                if($menu.cursor -gt 0){
                    $menu.Cursor--
                }
            }
            "RightArrow" {
                if($menu.cursor -lt $menu.Items.Count-1){
                    $Menu.Cursor++
                }
            }
            "DownArrow" {
            if($menu.cursor -lt $menu.Items.Count-1){$Menu.Cursor++}}
            "Spacebar" {
                if(($global:Menu.Items[$global:Menu.Cursor].Selected -eq 0) -and ($global:Menu.Items[$global:Menu.Cursor].Selectable -gt 0)){
                    $global:Menu.Items[$global:Menu.Cursor].Selected = 1
                }else{
                    if($global:Menu.Items[$global:Menu.Cursor].Selected -gt 0 -and ($global:Menu.Items[$global:Menu.Cursor].Selectable -gt 0)){
                        $global:Menu.Items[$global:Menu.Cursor].Selected = -1
                    }else{
                        $global:Menu.Items[$global:Menu.Cursor].Selected = 0
                    }
                }
            }
            "*"{
                paintScreen;
            }
            "Enter" {
                & $global:Menu.Items[$global:Menu.Cursor].Command
            }
        }
    }
    else{
        switch -wildcard (read-host "Enter + or - to move the cursor, Space to switch selection status of an item, = to run the menu item"){
            "+"{if($global:menu.cursor -lt $global:menu.Items.Count-1){$global:Menu.Cursor++}}
            "-"{if($global:menu.cursor -gt 0){$global:Menu.Cursor--}}
            " "{
                if(($global:Menu.Items[$global:Menu.Cursor].Selected -eq 0) -and ($global:Menu.Items[$global:Menu.Cursor].Selectable -gt 0)){
                    $global:Menu.Items[$global:Menu.Cursor].Selected = 1
                }else{
                    if($global:Menu.Items[$global:Menu.Cursor].Selected -gt 0 -and ($global:Menu.Items[$global:Menu.Cursor].Selectable -gt 0)){
                        $global:Menu.Items[$global:Menu.Cursor].Selected = -1
                    }else{
                        $global:Menu.Items[$global:Menu.Cursor].Selected = 0
                    }
                }
            }
            "*"{paintScreen}
            "="{& $global:Menu.Items[$global:Menu.Cursor].Command;write-host "";}       
        }
    }
}

paintScreen

while($true){
    menuStep
}