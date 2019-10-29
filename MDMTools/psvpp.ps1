function get-VPPLicenses{
	param(
		$VPPTokenFile =(read-host "Path to VPP Token file"), # Full Path to VPP Token File
		$assignedOnly = $true,
		$userAssignedOnly = $false,
		$deviceAssignedOnly = $false,
		$BatchID = "",
		$sinceModifiedToken
	)

	$Uri = 'https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/getVPPLicensesSrv' #This could change - check https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/VPPServiceConfigSrv for the service URLs
	$Form = @{
		'sToken'  = (get-content $VPPTokenFile); #If the dynamic loading of the token fails, just replace the (blah) with a string containing the base64 payload from the file
		'assignedOnly' = $assignedOnly;
		'userAssignedOnly' = $userAssignedOnly;
		'deviceAssignedOnly' = $deviceAssignedOnly;
		'sinceModifiedToken'= $sinceModifiedToken;
		'BatchID'= $BatchID
	}
	$Result = Invoke-RestMethod -Uri $Uri -Method Get -Body $Form
	return $result.licenses 	
}

function get-VPPAssets{
	param(
		$VPPTokenFile = (read-host "Path to VPP Token file"), # Full Path to VPP Token File
		$includeLicenseCount = $true
	)

	$Uri = 'https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/getVPPAssetsSrv' #This could change - check https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/VPPServiceConfigSrv for the service URLs
	$Form = @{
		'sToken'  = (get-content $VPPTokenFile); #If the dynamic loading of the token fails, just replace the (blah) with a string containing the base64 payload from the file
		'includeLicenseCounts' = $includeLicenseCount
	}
	$Result = Invoke-RestMethod -Uri $Uri -Method Get -Body $Form
	return $result.assets	
}

function get-VPPUsers{
	param(
		$VPPTokenFile = (read-host "Path to VPP Token file"), # Full Path to VPP Token File
		$batchToken = "",
		$sinceModifiedToken = "",
		$includeRetired = "0",
		$includeRetiredOnly = "0"
	)

	$Uri = 'https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/getVPPAssetsSrv' #This could change - check https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/VPPServiceConfigSrv for the service URLs
	$Form = @{
		'sToken'  = (get-content $VPPTokenFile); #If the dynamic loading of the token fails, just replace the (blah) with a string containing the base64 payload from the file
		'batchToken' = $batchToken;
		'sinceModifiedToken' = $sinceModifiedToken;
		'includeRetired' = $includeRetired;
		'includeRetiredOnly' = $includeRetiredOnly;
	}
	$Result = Invoke-RestMethod -Uri $Uri -Method Get -Body $Form
	return $result.users	
}

function get-VPPUser{
	param(
		$VPPTokenFile = (read-host "Path to VPP Token file"), # Full Path to VPP Token File
		$userID = "",
		$clientUserIdStr = (read-host "If a userID was also not set, this MUST be provided. ClientUserIDStr"),
		$itsIdHash = "",
	)

	$Uri = 'https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/getVPPAssetsSrv' #This could change - check https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/VPPServiceConfigSrv for the service URLs
	$Form = @{
		'sToken'  = (get-content $VPPTokenFile); #If the dynamic loading of the token fails, just replace the (blah) with a string containing the base64 payload from the file
		'userID' = $userID;
		'clientUserIdStr' = $clientUserIdStr;
		'itsIdHash' = $itsIdHash;
	}
	$Result = Invoke-RestMethod -Uri $Uri -Method Get -Body $Form
	return $result.user
}

<#
## THIS DOESN'T WORK, it's also not a GET, so don't fix it - leaving for historical reasons ##
function get-VPPCliCfg{
	param(
		$VPPTokenFile = (read-host "Path to VPP Token file"), # Full Path to VPP Token File
		$verbose = $false
	)
	$Uri = 'https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/VPPClientConfigSrv' #This could change - check https://vpp.itunes.apple.com/WebObjects/MZFinance.woa/wa/VPPServiceConfigSrv for the service URLs
	$Form = @{
		'sToken'  = (get-content $VPPTokenFile); #If the dynamic loading of the token fails, just replace the (blah) with a string containing the base64 payload from the file
		'verbose' = $verbose
	}
	$Result = Invoke-RestMethod -Uri $Uri -Method Post -Body $Form
	return $result	
}
#>
