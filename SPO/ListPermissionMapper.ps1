# Name: Generate-ListPermissionTree
#
# Description: This script runs through all folders and files in a doc library recursively, taking note of the permission structrure of any unique 
# permission set, then returns an XML structure as String or optionally stores the output to the specified outputfile. This requires the latest version of CSOM and PS 5.1
#
# Usage: . .\Generate-ListPermissionTree.ps1 -site "SiteUrl" -list "LibraryName" [-creds <O365 Credentials>] [-outputFile "Drive:\Path\File.xml"] [-sleepDelay <Milliseconds>]
# Example: . .\Generate-ListPermissionTree.ps1 -site "https://contoso.sharepoint.com/sites/TestSite" -list "Documents" -creds (get-credential) -outputFile "C:\Temp\SpDocLibPermissions.xml" -sleepDelay 1000

param(
    [System.Management.Automation.PSCredential]$creds = [System.Management.Automation.PSCredential]::Empty,
    [Parameter(Mandatory=$true)]$site,
    [Parameter(Mandatory=$true)]$list,
    $outputFile,
    $sleepdelay = 0
)


# Import CSOM modules

Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.DocumentManagement.dll" 
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll" 

#Define necessary functions

function generate-listpermissiontree{
  param(
    [System.Management.Automation.PSCredential]$creds = [System.Management.Automation.PSCredential]::Empty,
    [Parameter(Mandatory=$true)]$site,
    [Parameter(Mandatory=$true)]$list
  )
    #Here's where it starts. Gather credentials, set up context, load site, load list, start scan, then return the result
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($creds.UserName , $creds.Password)
    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($site)
    $ctx.Credentials = $Credentials   

    $rootWeb = $ctx.Web  
    $ctx.Load($rootWeb) 
    $ctx.ExecuteQuery()
    $spList = $rootWeb.Lists.GetByTitle($list)
    $ctx.Load($splist)
    $ctx.executequery()
    $rootFolder = $splist.RootFolder
    $ctx.Load($rootFolder)
    $ctx.ExecuteQuery()
    $rootPrep = @($rootFolder)
    $finalXML = (GenListPermissionTree-expandFolder -Folder $rootFolder -ctx $ctx)
    return $finalXML

}

function GenListPermissionTree-expandFolders{
  param(
    [Parameter(Mandatory=$true)]$Folders,
    [Parameter(Mandatory=$true)]$ctx
  )
  #This is really just a wrapper for folder collections, which then goes back into the mapper function for each folder
  $Foldersresult = ""
  foreach($Folder1 in $Folders){
    $Foldersresult+=GenListPermissionTree-expandFolder -Folder $Folder1 -ctx $ctx
  }
  return $Foldersresult
}

function GenListPermissionTree-expandFolder{
  param(
    [Parameter(Mandatory=$true)]$Folder,
    [Parameter(Mandatory=$true)]$ctx
  )
    # This is the mapper. It collects the details of the current folder's permissions and puts them in the string, then 
    # enumerates the files and their details, then runs GenListPermissionTree-expandFolders on the subfolders collection

    $ctx.load($Folder)
    $ctx.ExecuteQuery()
    $Folderresult +='<Folder name="'+$Folder.name+'"'
    try{
        $i = $Folder.ListItemAllFields
        load-csomproperties -object $i -propertynames @("HasUniqueRoleAssignments")
        $ctx.ExecuteQuery()
        $ctx.load($i)
        $ctx.ExecuteQuery()
        $rac = $i.RoleAssignments
        $ctx.load($rac)
        $ctx.ExecuteQuery()
    }
    catch{

    }
    if($i.HasUniqueRoleAssignments -eq $true){
        $Folderresult += ' unique="'+$i.HasUniqueRoleAssignments+'"'
    }
    $Folderresult +='>'
    if($i.HasUniqueRoleAssignments -eq $true){
        foreach($ra in $rac){
            $ctx.load($ra.member)
            $ctx.executequery()
            $Folderresult += '<Permission object="'+$ra.Member.LoginName+'" Permissions="'
            $rdb = $ra.RoleDefinitionBindings
            $ctx.load($rdb)
            $ctx.ExecuteQuery()
            foreach($rd in $rdb){
                $Folderresult+=$rd.Name+";"
            }
            $Folderresult+='"/>'
        }
        
    }
    start-sleep -milliseconds $sleepdelay
    $ctx.load($Folder.Files)
    $ctx.ExecuteQuery()
    foreach($f in $Folder.Files){ 
        try{   
        $i = $f.ListItemAllFields
        load-csomproperties -object $i -propertynames @("HasUniqueRoleAssignments")
        $ctx.ExecuteQuery()
        $ctx.load($i)
        $ctx.ExecuteQuery()
        $rac = $i.RoleAssignments
        $ctx.load($rac)
        $ctx.ExecuteQuery()
        }
        catch{}
        $Folderresult+='<File name="'+$f.Name+'"'
        if($i.HasUniqueRoleAssignments -eq $true){
            $Folderresult += ' unique="'+$i.HasUniqueRoleAssignments+'"'
        }
        
         $Folderresult += '>'
        if($i.HasUniqueRoleAssignments -eq $true){
            foreach($ra in $rac){
                $ctx.load($ra.member)
                $ctx.executequery()
                $Folderresult += '<Permission Login="'+$ra.Member.LoginName+'" Title="'+$ra.Member.Title+'" Permissions="'
                $rdb = $ra.RoleDefinitionBindings
                $ctx.load($rdb)
                $ctx.ExecuteQuery()
                foreach($rd in $rdb){
                    $Folderresult+=$rd.Name+"; "
                }
                $Folderresult+='" />'
            }
        }
        $Folderresult +="</File>"        
        start-sleep -milliseconds $sleepdelay
    }
    $ctx.load($Folder.Folders)
    $ctx.ExecuteQuery()
    $Folderresult += GenListPermissionTree-expandFolders $Folder.Folders $ctx
    $Folderresult += "</Folder>"
    return $Folderresult
}

function Load-CSOMProperties {
    # This was taken from https://gist.github.com/glapointe/cc75574a1d4a225f401b 
    # and is a workaround to be able to target Sharepoint Properties usually necessitating Lambda Operators to retrieve
    [CmdletBinding(DefaultParameterSetName='ClientObject')]
    param (
        # The Microsoft.SharePoint.Client.ClientObject to populate.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = "ClientObject")]
        [Microsoft.SharePoint.Client.ClientObject]
        $object,
        # The Microsoft.SharePoint.Client.ClientObject that contains the collection object.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = "ClientObjectCollection")]
        [Microsoft.SharePoint.Client.ClientObject]
        $parentObject,
        # The Microsoft.SharePoint.Client.ClientObjectCollection to populate.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ClientObjectCollection")]
        [Microsoft.SharePoint.Client.ClientObjectCollection]
        $collectionObject,
        # The object properties to populate
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "ClientObject")]
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "ClientObjectCollection")]
        [string[]]
        $propertyNames,
        # The parent object's property name corresponding to the collection object to retrieve (this is required to build the correct lamda expression).
        [Parameter(Mandatory = $true, Position = 3, ParameterSetName = "ClientObjectCollection")]
        [string]
        $parentPropertyName,
        # If specified, execute the ClientContext.ExecuteQuery() method.
        [Parameter(Mandatory = $false, Position = 4)]
        [switch]
        $executeQuery
    )
    begin { }
    process {
        if ($PsCmdlet.ParameterSetName -eq "ClientObject") {
            $type = $object.GetType()
        } else {
            $type = $collectionObject.GetType() 
            if ($collectionObject -is [Microsoft.SharePoint.Client.ClientObjectCollection]) {
                $type = $collectionObject.GetType().BaseType.GenericTypeArguments[0]
            }
        }
        $exprType = [System.Linq.Expressions.Expression]
        $parameterExprType = [System.Linq.Expressions.ParameterExpression].MakeArrayType()
        $lambdaMethod = $exprType.GetMethods() | ? { $_.Name -eq "Lambda" -and $_.IsGenericMethod -and $_.GetParameters().Length -eq 2 -and $_.GetParameters()[1].ParameterType -eq $parameterExprType }
        $lambdaMethodGeneric = Invoke-Expression "`$lambdaMethod.MakeGenericMethod([System.Func``2[$($type.FullName),System.Object]])"
        $expressions = @()
        foreach ($propertyName in $propertyNames) {
            $param1 = [System.Linq.Expressions.Expression]::Parameter($type, "p")
            try {
                $name1 = [System.Linq.Expressions.Expression]::Property($param1, $propertyName)
            } catch {
                Write-Error "Instance property '$propertyName' is not defined for type $type"
                return
            }
            $body1 = [System.Linq.Expressions.Expression]::Convert($name1, [System.Object])
            $expression1 = $lambdaMethodGeneric.Invoke($null, [System.Object[]] @($body1, [System.Linq.Expressions.ParameterExpression[]] @($param1)))
            if ($collectionObject -ne $null) {
                $expression1 = [System.Linq.Expressions.Expression]::Quote($expression1)
            }
            $expressions += @($expression1)
        }
        if ($PsCmdlet.ParameterSetName -eq "ClientObject") {
            $object.Context.Load($object, $expressions)
            if ($executeQuery) { $object.Context.ExecuteQuery() }
        } else {
            $newArrayInitParam1 = Invoke-Expression "[System.Linq.Expressions.Expression``1[System.Func````2[$($type.FullName),System.Object]]]"
            $newArrayInit = [System.Linq.Expressions.Expression]::NewArrayInit($newArrayInitParam1, $expressions)
            $collectionParam = [System.Linq.Expressions.Expression]::Parameter($parentObject.GetType(), "cp")
            $collectionProperty = [System.Linq.Expressions.Expression]::Property($collectionParam, $parentPropertyName)
            $expressionArray = @($collectionProperty, $newArrayInit)
            $includeMethod = [Microsoft.SharePoint.Client.ClientObjectQueryableExtension].GetMethod("Include")
            $includeMethodGeneric = Invoke-Expression "`$includeMethod.MakeGenericMethod([$($type.FullName)])"
            $lambdaMethodGeneric2 = Invoke-Expression "`$lambdaMethod.MakeGenericMethod([System.Func``2[$($parentObject.GetType().FullName),System.Object]])"
            $callMethod = [System.Linq.Expressions.Expression]::Call($null, $includeMethodGeneric, $expressionArray) 
            $expression2 = $lambdaMethodGeneric2.Invoke($null, @($callMethod, [System.Linq.Expressions.ParameterExpression[]] @($collectionParam)))
            $parentObject.Context.Load($parentObject, $expression2)
            if ($executeQuery) { $parentObject.Context.ExecuteQuery() }

        }
    }
    end { }

}


#Now that the functions are loaded, run them and collect the result. If an output file was defined, save the output to the file. Otherwise return the XML as string

#Check Credentials set
if($creds -eq [System.Management.Automation.PSCredential]::Empty){
    $creds = (get-credential)
}

#Either save or return
if($outputFile -eq $null){
    return generate-listpermissiontree -creds $creds -site $site -list $list
}
else{
    generate-listpermissiontree -creds $creds -site $site -list $list | out-file $outputFile
    write-host -foregroundcolor Green ("Report completed! Saved to: " + $outputfile +". Opening now....")
    start-process "C:\Program Files (x86)\Internet Explorer\iexplore.exe" $outputfile
}
