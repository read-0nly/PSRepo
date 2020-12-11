$hash = (read-host "Paste the payload here, without spaces newlines").replace("`n","").replace("`r","").replace("`t","")
$while = $true
while ($while){
    try{
        [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($hash)) >> $null
        $while = $false
        }
    catch{
        if(($hash.ToCharArray()[-1]-eq '=') -and ($hash.ToCharArray()[-2]-eq '=')){
            $hash = $hash.replace("=","")
            $hash= ($hash+"A")
        }
        else{
            $hash= ($hash+"=")
        }
    }
}
write-host "Hash padded! Here it is:" -foregroundcolor green
$hash
