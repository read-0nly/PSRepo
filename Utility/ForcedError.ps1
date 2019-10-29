  
Write-Error -Message "Forced Fail" -Category OperationStopped
mkdir "c:\temp" 
echo "Forced Fail" | out-file c:\temp\Fail.txt
