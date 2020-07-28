#Cheap token generation, uses the intune samples scripts to generate the token then uses it to query /me. Returned token is AuthToken
#install-module azuread
import-module azuread
$global:CompanyPortal_Get = (iwr "https://raw.githubusercontent.com/microsoftgraph/powershell-intune-samples/master/CompanyPortalBranding/CompanyPortal_Get.ps1" -usebasicparsing).content
function refreshConnection(){
    $Tenant = (iex $global:CompanyPortal_Get)
}

function execute-Step(){
    param(
        [pscustomobject] $step
    )
    if($step.Body -ne $null){
        PSObj2Hashtable (Invoke-RestMethod -Uri $step.Endpoint -Headers $authToken -Method $step.Method -Body ([System.Text.Encoding]::UTF8.getString([convert]::FromBase64String($step.Body))));
    }else{
        PSObj2Hashtable (Invoke-RestMethod -Uri $step.Endpoint -Headers $authToken -Method $step.Method)
    }
}

function verify-Step(){
    param(
        [pscustomobject]$step
    )
    $Compare = PSObj2Hashtable (([System.Text.Encoding]::UTF8.getString([convert]::FromBase64String($step.ExpectedResult))) | convertfrom-json)
    $result = PSObj2Hashtable (Invoke-RestMethod -Uri $step.Endpoint -Headers $authToken -Method $step.Method)
    hashcompare $result $Compare
}

function hashCompare(){
    param($result,$expectedresult)
    $Success = $true
    if($result.value -ne $null){
        if($result.value.length -gt 0 -and $result.value.length -ne 1){
            $success = $false
            for($i = 0; $i -lt $result.value.length;$i++){
                $resultBool =(hashcompare $result.value[$i] $expectedresult)
                $Success = ($Success -or $resultBool)
            }
        }
        else{
            $success = $false
            $resultBool =(hashcompare $result.value $expectedresult)
            $Success = ($Success -or $resultBool)

        }
    }
    else{
        $expectedresult.keys.split("`n") | %{
            if($expectedresult[$_].getType().name -eq "Hashtable"){
                $success = ($success -and (hashCompare $result[$_] $expectedresult[$_]))
            }
            else{
                # write-host ($_ + " : " + ($result[$_] -eq $expectedresult[$_]) #For Debugging
                $success = ($success -and ($result[$_] -eq $expectedresult[$_]))
                if($_ -eq "bitLockerEncryptDevice"){
                $x = $x
                }
            }
        }
    }
    return ($success)

}

#Helper function - turns the imported PSCustomObject to a Hashtable
function PSObj2Hashtable(){
    param($PSObj)
    $PSObj2Hashtable = @{}
    $Keys = ($PSObj| Get-Member | where-object {$_.MemberType -eq "NoteProperty"}).Name
    $Keys | %{
        $valueFetch = [scriptblock]::Create(('param($PSObj); echo ($PSObj."'+$_+'")'));
        $value = (Invoke-Command $valueFetch -ArgumentList $PSObj)
        if($value -ne $null -and $value.gettype().name -eq "PSCustomObject"){
            $value = (PSObj2Hashtable $value)
        }
        $PSObj2Hashtable.add($_,$value);

    }
    return $PSObj2Hashtable
}