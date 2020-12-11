param(
	$filePath
)

function Get-FreshAutopilot{
	param(
		$filePath = (read-host "Please enter a path to save the CSV file"),
        $IncludeOrder = $false
	)
	$allDevices = get-azureaddevice | select-object * | where-object {$bool = $false; $_.devicephysicalids | %{$bool = ($bool -or ($_ -like "*ZTDID*"))};echo $bool}
    if(-not $IncludeOrder){
	    $allDevices = $allDevices | where-object {$bool = $false; $_.devicephysicalids | %{$bool = ($bool -or ($_.toUpper() -like "*ORDERID*"))};echo (-not $bool)}
	    $allDevices | select-object displayname, objectid, orderid | export-csv $filePath
    }
}

function Set-FreshAutopilot{
	param(
		$filePath = (read-host "Please enter a path to load the CSV file")
	)
	$csvTable = import-csv $filePath
	$csvTable | %{ 
		$curDev = get-azureaddevice -objectid $_.objectid | select-object *
        $newDevIDs = new-object System.Collections.ArrayList
        $newDevIDs.addRange($curDev.DevicePhysicalIDs)
        for($i = 0; $i -lt $newDevIDs.Count; $i++){
            if($newDevIDs[$i].toUpper() -like "*ORDERID*"){
                $newDevIDs.removeAT($i)
                $i--;
            }
        }
        if($_.orderID -ne $null -and $_.orderid.length -gt 0){
            ([System.Collections.ArrayList]$newDevIDs).addRange(@("[OrderID]:"+$_.orderid))
        }
		set-azureaddevice -objectid $curDev.objectid -devicephysicalids ([array]$newDevIDs)
	}
}

function GnS-FreshAutopilot{
	param(
		$filePath = (read-host "Please enter a path for the CSV file")
	)
    Connect-azuread
    Get-FreshAutopilot $filePath
    write-host "Export Complete!" -ForegroundColor Green
    $null = Read-Host "Please edit the CSV file, then press any key to continue"
    set-FreshAutopilot $filePath
    write-host "Import Complete!" -ForegroundColor Green
}



if($filePath -ne $null){
    GnS-FreshAutopilot $filePath
}
ELSE{
    GnS-FreshAutopilot
}