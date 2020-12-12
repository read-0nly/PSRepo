#
<#

To run this the cheap (and dynamic!) way: 
iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/Menu.ps1" -usebasicparsing).content.replace([char](65279),' ')

#>

$global:menu = [pscustomobject]@{
    "MenuState" = 1
    "Settings" = @{
        "Vertical" = $true;
        "Width"=50;
        "Spacer" = "|";
        "SelectionRange" = @(-1,0,1);
        "SelectionColors" = @("DarkRed","DarkGray","DarkGreen")
        "SelectionColorcodes" = @(([char]27+"[0m"),([char]27+"[101m"),([char]27+"[100m"),([char]27+"[42m"))
        "HoverColor"= [char]27+"[7m"
        "ColorMiddle" = 2
    };
    "Cursor" = 1;
    "Items" = @(
        [pscustomobject]@{
            "Name" = "AutoPad-Base64";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/AutoPad-Base64.ps1" -usebasicparsing).content.replace([char](65279),' ').replace([char](65279),' ')};
            "Selected" = -1;
            "Selectable" = 0;
            "Description" = "When provided unpadded base64, will hammer the padding until it's valid padded base64";
        },    
        [pscustomobject]@{
            "Name" = "AutopilotAssigner";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/AutopilotAssigner.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = -1
            "Selectable" = 0
            "Description" = "Pulls autopilot devices with no OrderID into a csv. Edit it with the desired orderIDs, then continue the script to update the batch";
        },   
        [pscustomobject]@{
            "Name" = "Generate-AppcontrolExcusions";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/Generate-AppcontrolExcusions.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = -1
            "Selectable" = 0
            "Description" = "Pulls all the win32 apps defined in Intune and creates app control policies based off the path leading up to the file in the detection rule";
        },    
        [pscustomobject]@{
            "Name" = "Search-SettingInPolicies";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/Search-SettingInPolicies.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = -1
            "Selectable" = 0
            "Description" = "Given the name of a setting (https://docs.microsoft.com/en-us/mem/intune/developer/graph-apis-used-by-intune-device-configuration-windows), returns all policies with that setting from Intune";
        }, 
        [pscustomobject]@{
            "Name" = "EVTXRipper";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/EVTXRipper.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 0
            "Selectable" = 0
            "Description" = "Given a folder of EVTX files, combines then trims them down to errors then tries to find references of those error codes. Can be a good place to start on weird stuff";
        },    
        [pscustomobject]@{
            "Name" = "HashDuplicateSearch";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/HashDuplicateSearch.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 0
            "Selectable" = 0
            "Description" = "(WIP) Creates a file hash database with the intent of then finding all data dupes across a folder structure";
        },   
        [pscustomobject]@{
            "Name" = "LogCollector";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/LogCollector.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 0
            "Selectable" = 0
            "Description" = "Collects logs depending on the scenario";
        },          
        [pscustomobject]@{
            "Name" = "BatchJPG";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/BatchJPG.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 1
            "Selectable" = 0
            "Description" = "Adds the extension .jpg to all files in a folder - handy for finding images with no extension";
        },    
        [pscustomobject]@{
            "Name" = "InterTransmission";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/InterTransmission.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 01
            "Selectable" = 0
            "Description" = "Types the given value or file to the first window matching the given title";
        },   
        [pscustomobject]@{
            "Name" = "Mounter";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/Mounter.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 01
            "Selectable" = 0
            "Description" = "Mounts/unmounts the given VHD";
        },   
        [pscustomobject]@{
            "Name" = "Set-AADAutologon";
            "Command" = [scriptBlock]{. iex (iwr "https://raw.githubusercontent.com/read-0nly/PSRepo/master/MDMTools/The%20Toolkit/SetAADAutoLogon.ps1" -usebasicparsing).content.replace([char](65279),' ')};
            "Selected" = 01
            "Selectable" = 0
            "Description" = "Configures autologon for an azure user";
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
    $string = $menu.settings["selectionColorCodes"][$menu.settings["ColorMiddle"] + $entry.selected]+(&{if($entry.Name -eq $Menu.Items[$menu.Cursor].name){ $menu.settings["HoverColor"]}else{""}}) + $string + $menu.settings["selectionColorCodes"][0]
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
    cls
    write-host
    write-host "Welcome to The Toolkit" -foregroundcolor red
    write-host "A mix of utility scripts, mostly for managing azure/intune/devices" -foregroundcolor cyan
    write-host 
    write-host
    paintMenu $currentMenu.Value
    write-host
    write-host $global:Menu.Items[$global:Menu.Cursor].Description -foregroundcolor yellow
    write-host

}

function menuStep(){
    if($psISE -eq $null){
        write-host "Arrows to move between items, Enter to execute, Space to select (not relevant yet)"
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