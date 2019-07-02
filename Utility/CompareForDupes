# Name: DuplicationFunctions
function Compare-FolderDupes{
	param(
		$folderA=(read-host "Enter the path of the first folder without quotes"),
		$folderB=(read-host "Enter the path of the second folder without quotes")
	)

	$local:folderLSA = (ls $local:folderA -file -recurse)
	$local:folderLSB = (ls $local:folderB -file -recurse)
	$local:folderAHash = @{}
	$local:DupeTable = @()

	foreach($local:fileA in $local:folderLSA){
		$local:relativePath = $local:fileA.fullname.toUpper().replace($local:folderA.toUpper(),"")
		$local:folderAHash.add($local:relativePath, $local:fileA.fullname)
	}

	foreach($local:fileB in $local:folderLSB){
		$local:relativePath = $local:fileB.fullname.toupper().replace($local:folderB.toUpper(),"")
		try{
			if((get-filehash $local:folderAHash[$local:relativePath]).hash -eq (get-filehash $local:fileB.fullname).hash){
				$local:DupeTable+=@(
					[PSCustomObject]@{Name=$local:relativePath
						PathA=$local:folderAHash[$local:relativePath]
						PathB=$local:fileB.fullname
						isDupe=$true
					}
				)
			}else{
				$local:DupeTable+=@(
					[PSCustomObject]@{Name=$local:relativePath
						PathA=$local:folderAHash[$local:relativePath]
						PathB=$local:fileB.fullname
						isDupe=$false
					}
				)
			}		
		}
		catch{
			write-host "error using reference "+$local:relativePath
		}
		
		
	}

	$local:dupetable
}

function Pick-Keeper{
	param(		
		$fileA,
		$fileB,
		$safe = $true
	)
	$local:Outcome = New-Object PSObject -Property @{
		Keep = ""
		Toss = ""
		CorruptCandidates = @()
	}
	if([System.io.File]::getLastWriteTime($local:fileA) -eq [System.io.File]::getLastWriteTime($local:fileB)){
		$local:Outcome.CorruptCandidates += @($local:fileA)
		$local:Outcome.CorruptCandidates += @($local:fileB)
	}
	else{
		$local:result = New-Object PSObject -Property @{
			Keep = ""
			Toss = ""
		}
		if([System.io.File]::getLastWriteTime($local:fileA) -gt [System.io.File]::getLastWriteTime($local:fileB)){					
			if($local:safe){
				$local:result = Query-Keeper -newer $local:fileA -older $local:fileB
			}else{
				$local:result.keep = $local.fileA
				$local:result.toss = $local.fileB
			}
		
		}
		else{		
			if($local:safe){
				$local:result = Query-Keeper -newer $local:fileB -older $local:fileA
			}else{
				$local:result.keep = $local.fileB
				$local:result.toss = $local.fileA
			}
		}
		$local:Outcome.Keep = $local:result.Keep
		$local:Outcome.Toss = $local:result.Toss	
		
	}

	$local:Outcome
}

function Query-Keeper{
	param(
		$newer,
		$older
	)
	$local:Outcome = New-Object PSObject -Property @{
		Keep = "" 
		Toss = "" 
	}
	write-host "(1)The newer file is: " -nonewline; write-host $newer -foregroundcolor Green
	write-host "(2)The older file is: " -nonewline; write-host $older -foregroundcolor Yellow
	$local:validSelection = $false
	while(-not $local:validSelection){
		switch(read-host "Keep which file? (1/2)"){
			1{
				$local:Outcome.Keep = $newer
				$local:Outcome.Toss = $older
				$local:validSelection = $true
			}
			2{
				$local:Outcome.Keep = $newer
				$local:Outcome.Toss = $older							
				$local:validSelection = $true
			}
			default{}
		}
	}
	$local:Outcome
}

function Combine-FolderDupes{
	param(
		$folderA=(read-host "Enter the path of the first folder without quotes"),
		$folderB=(read-host "Enter the path of the second folder without quotes"),
		$OutputFolder=(read-host "Enter the path of the output folder without quotes"),
		$DupeTableInput=(Compare-FolderDupes -folderA $local:folderA -folderB $local:folderB),
		$Safe = $true
	)
	#We need two lists - files to keep, and files to remove. Initialize list
	$local:Outcome = New-Object PSObject -Property @{
		Keep = @() 
		Toss = @() 
		CorruptCandidates = @()
		DupeTable = $local:DupeTableInput
	}
	
	#Go through each file, and 
	foreach($local:duplicate in $local:DupeTableInput){
		if($local:duplicate.isDupe){
			$local:Outcome.Keep+=@($local:duplicate.PathA)
			$local:Outcome.toss+=@($local:duplicate.PathB)		
		}
		else{
			$local:result = Pick-Keeper -fileA $local:duplicate.PathA -fileB $local:duplicate.PathB -safe $local:safe
			$local:Outcome.Keep += @($local:result.Keep)
			$local:Outcome.Toss += @($local:result.Toss)
		}
	}
	$outcome
}

function Apply-FileTransform{
	Param(
		$Safe = $true,
		$folderA=(read-host "Enter the path of the first folder without quotes"),
		$folderB=(read-host "Enter the path of the second folder without quotes"),
		$outputFolder = (read-host "Enter the path of the output folder without quotes"),
		$Transforms = (Combine-FolderDupes -safe $local:safe -outputfolder $local:outputfolder -folderA $local:folderA -folderB $local:folderB)
	)
	if($local:safe){
		Write-host "Starting Deletion Cycle" -foregroundcolor Red
		foreach($local:item in $local:Transforms.Toss){
			if((read-host """$item"" is marked for deletion. Delete? (y/n)""").toUpper() -eq "Y"){
				del $local:item
			}
		}
		foreach($local:item in $local:Transforms.Keep){
			if((read-host """$item"" is marked for keeping. Move to Output? (y/n)""").toUpper() -eq "Y"){
				try{
					$relativePath=$local:outputfolder+($local:item.toupper().replace($local:folderA.toUpper(),"").replace($local:folderB.toUpper(),""))
					$relativeParts = $relativePath.split("\")
					$relativeBranch = $relativePath.replace($relativeParts[$relativeParts.count-1], "")
					mkdir ($relativeBranch)
					[System.io.file]::move($local:item,$local:relativePath)
				}
				catch{
					write-host "RelPath: $relativePath"
					write-host "RelPath: $relativeParts"
					write-host "RelPath: $relativeBranch"
					write-host ("RelPath: "+($local:outputfolder+"\"+$local:relativebranch ))
				}
			}			
		}
	}
}
