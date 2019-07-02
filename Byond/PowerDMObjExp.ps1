$nakedScript = cat "human.dm"
$DefinitionStarts = new-object System.Collections.HashTable 
#Pull the start of every code block
for($i = 0;$i -lt $nakedScript.count;$i++){
    if($nakedScript[$i].StartsWith("/") -and -not $nakedScript[$i].StartsWith("//")){
        $DefinitionStarts.add($nakedScript[$i],$i)
    }
}
#Pull Functions from Classes
$Classes = new-object System.Collections.HashTable 
$Functions = new-object System.Collections.HashTable 
$DefinitionStarts.Keys|%{if($_ -match "\(.*\)"){$Functions.add($_,$DefinitionStarts[$_])}else{$Classes.add($_,$DefinitionStarts[$_])}}
