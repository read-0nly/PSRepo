<#
Returns all failing compliance settings across all devices, as a quick overview of what needs to be corrected on which devices.

Since the official microsoft.graph.intune module's get-devicemanagement_manageddevices_devicecompliancepolicystates cmdlet was broken 
(when provided a policy ID, it returned nothing - this is because when provided with a policy ID you also need to append /settingstates, 
per network trace of Intune UI) I had to rebuild it with a fix to get this to work. Hence the init function downloading my own personal 
build of the module. If/when https://github.com/microsoft/Intune-PowerShell-SDK/pull/82 gets merged, this whole section can be replaced 
with a #requires microsoft.graph.intune.
#>

    #Set root to current folder
	$root=".\"
	if($psscriptroot){
		$root = $PSScriptRoot
	}
function init(){
	param($root)
    cls
    write-host "Initialization Started" -ForegroundColor Green
    #Create intunelib folder as necessary
    $workpath = $root+"\intuneLib\"
    if(-not (test-path $workpath)){
        write-host "  Module library folder not found - Creating folder" -ForegroundColor Magenta
        mkdir $workpath >> $null
    }
    else{
        write-host "  Module folder found!" -ForegroundColor Green
    }
    #Download and expand fixed version of module if necessary
    #start-bitstransfer throws a 403, so IWR to the rescue!
    if(-not (test-path ($workpath+"debug.zip"))){
        write-host "  Module download not found - Initiating Module Download." -ForegroundColor Magenta
        #Get the byte blob of the fixed module release
        $moduleBytes = (invoke-webrequest https://github.com/read-0nly/Intune-PowerShell-SDK/files/4742195/Debug.zip).content
        #Don't use set-content for byte arrays - it's awful
        [system.io.file]::WriteAllBytes(($workpath+"debug.zip"),$moduleBytes)
        write-host "  Module downloaded - Unzipping module" -ForegroundColor Magenta
        #Unzip the release to the intunelib folder
        while(-not ( test-path ($workpath+"debug.zip") ) ){
        start-sleep -Milliseconds 10
        }
        expand-archive ($workpath+"debug.zip") $workpath    
    }
    else{
        write-host "  Module download found!" -ForegroundColor Green
    }
    #Import fixed module
    import-module ($workpath+"net471\microsoft.graph.intune.psd1")
    #if module is loaded, return true to allow execution
    if( (Get-Module | select-object name).name.tolower() -contains "microsoft.graph.intune"){
        write-host "  Module loaded!" -ForegroundColor Green
        return $true
    }

}

function getAllDevices(){
    #Get all devices, but just the relevant properties
    Get-DeviceManagement_ManagedDevices | 
        select-object id,devicename,azureaddeviceid,userprincipalname,operatingsystem,compliancestate,manageddeviceownertype

}
function getCompliancePolicies(){
    param($devices)
    #Hashtable to hold results
    $results = @{}
    #For each device, get their compliance policies, add to hashtable
    foreach($device in $devices){
        $results.add($device.id, (get-devicemanagement_manageddevices_devicecompliancepolicystates -managedDeviceId $device.id))
    }
    #Return results
    return $results
}

function getComplianceSettings(){
    param($devices,$policyTable)
    #Hashtable to hold results - the use of hashtables mostly makes sure there's no duplicates at the end of the process
    $policySettingTable =@{};
    foreach($device in $devices){
        #Nested hashtable to hold results - the use of hashtables mostly makes sure there's no duplicates at the end of the process
        $policySettingTable.add($device.id,@{})
        foreach($policy in ($policyTable[$device.id] | where-object {$_.state -eq "nonCompliant"})){
            #Create a custom object that combines the device, policy, and setting info into a single object
            $Entries = (get-devicemanagement_manageddevices_devicecompliancepolicystates -managedDeviceId $device.id -deviceCompliancePolicyStateId $policy.id).value | %{
                [pscustomobject]@{
                    "deviceName" = $device.devicename;
                    "deviceID" = $device.id;
                    "setting" = $_.setting;
                    "policyName" = $_.setting.split(".")[0];
                    "settingName" = $_.setting.split(".")[1];
                    "state" = $_.state;
                    "userPrincipalName" = $_.userPrincipalName;
                }
            }
            #Add or overwrite the setting entries to the nested hashtable
            $policySettingTable[$device.id][$policy.id]=$Entries
        }
    }
    #Return results
    return $policySettingTable
}

function getNonCompliantSettings(){
    $keys = ($settingStates.keys.split("`n"));
    #Strip the results down to needed properties, filter down to only the settings that report non-compliant
    foreach($key in $keys){
        ($settingStates[$key].keys | %{
            $settingStates[$key][$_] | select-object devicename, settingName, userprincipalName, state |
            where-object state -eq "nonCompliant"
        })
    }

}

#Execution
if((init $root)-eq $true){
    #Connect to MSGraph
    write-host "Success - Executing" -ForegroundColor Green
    Connect-MSGraph >> $null    
    #Get devices that are non-compliant
    write-host "  Getting Devices" -ForegroundColor Magenta
    $deviceList = (getAllDevices | where-object {$_.compliancestate -eq "noncompliant"})
    #Get the policies assigned to non-compliant devices
    write-host "  Getting Policy states" -ForegroundColor Magenta
    $complianceStates = getCompliancePolicies $deviceList
    #Get the settings of the non-compliant policies assigned to the devices
    write-host "  Getting Setting states" -ForegroundColor Magenta
    $settingStates = [system.collections.hashtable](getComplianceSettings $deviceList $complianceStates)    
    #Get the non-compliant settings of the policies assigned to the devices
    write-host "  Generating Report" -ForegroundColor Magenta
    $Report = getNonCompliantSettings
    $report | sort-object deviceName | ft
    #Save the report
    if((Read-Host "Enter 'Y' to save").toupper() -eq "Y"){
        $report | export-csv (read-host "Enter desired full path of new CSV file")
    }
}
else{
    write-host "Failed - Exiting" -ForegroundColor Red
}
