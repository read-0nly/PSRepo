(dir . -recurse)|%{if($_.gettype().name -eq "FileInfo"){mv $_.FullName ($_.Directory.FullName + "\" + $_.name + ".jpg")}else{}}
