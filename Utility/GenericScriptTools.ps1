# Description: Verifies that prerequisites are met and installs what is missing
# Date: 12/20/18
# Usage Examples: Configure-prerequisitemodules @("AzureAD","MSOnline","WindowsAutopilotIntune")
# Return: Bool - represents if environment is configured properly and modules loaded successfully

function Configure-PrerequisiteModules{
param(
    [string[]]$requiredModules
)
    # Installs the modules to interact with o365
    $allSet =[bool]([int]((host).version.Major) -ge 5)
    if($allSet){
        foreach($module in $requiredModules){
            if(get-module -listavailable -name $module){
                Write-Host ($module+" installed") -ForegroundColor Green
                get-module -listavailable -name $module | %{import-module $_}
            } 
            else {
                Write-Host ($module+" not installed") -ForegroundColor Red
                try{
                    install-module $module
                    get-module -listavailable -name $module | %{import-module $_}
                }
                catch{            
                    Write-Host ($module+" cannot be installed - Are you running as Admin?") -ForegroundColor Red            
                    $allSet = $false;
                }
            }
        }
        return $allSet
    }
    else{
        Write-Host ("Please update to at least WMF 5.1 to proceed") -ForegroundColor Red -BackgroundColor Black
        start "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
        return $allSet
    }
}
function Configure-PrerequisiteScripts{
param(
    [int]$minMajorVersion,
    [string[]]$requiredScripts
)
    # Installs the modules to interact with o365
    $allSet =[bool]([int]((host).version.Major) -ge $minMajorVersion)
    if($allSet){
        foreach($script in $requiredScripts){
            if(get-script -listavailable -name $script){
                Write-Host ($script+" installed") -ForegroundColor Green
            } 
            else {
                Write-Host ($script+" not installed") -ForegroundColor Red
                try{
                    install-script $script
                }
                catch{            
                    Write-Host ($script+" cannot be installed - Are you running as Admin?") -ForegroundColor Red            
                    $allSet = $false;
                }
            }
        }
        return $allSet
    }
    else{
        Write-Host ("Please update to at least WMF 5.1 to proceed") -ForegroundColor Red -BackgroundColor Black
        start "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
        return $allSet
    }
}
