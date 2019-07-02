    #So there's a bug that can happen, where NewDocumentTemplates is empty without being null. It should contain what file types are 
    #available. Null defaults to the default typeset. If it's an available file type, but it's not enabled for this list, it should 
    #be in the string with visible:false
    #Here's what it usually looks like: 
    #[{"title":"Folder","visible":true},{"title":"Word document","visible":true},{"title":"Excel workbook","visible":true},{"title":"PowerPoint presentation","visible":true},{"title":"OneNote notebook","visible":true},{"title":"Forms for Excel","visible":true}]
    #If this is in fact an emptry set instead of Null, the file type is not available to add back to the "New" dropdown.
    
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.DocumentManagement.dll" 
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 
    Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll" 
    #Here's where it starts. Gather credentials, set up context, load site, load list, start scan, then return the result
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($creds.UserName , $creds.Password)
    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext((read-host "Please input the site url"))
    $ctx.Credentials = $Credentials   

    $rootWeb = $ctx.Web  
    $ctx.Load($rootWeb) 
    $ctx.ExecuteQuery()
    $spList = $rootWeb.Lists.GetByTitle((read-host "Please input the list name"))
    $ctx.Load($splist)
    $ctx.executequery()
    $views = $splist.Views
    $ctx.load($views)
    $ctx.ExecuteQuery()
    foreach($view in $views){
        $view.Retrieve("NewDocumentTemplate")
        $ctx.ExecuteQuery()
        $view.title
        $view.NewDocumentTemplates        
        $view.NewDocumentTemplates = $view.NewDocumentTemplates #Set it to itself - just to document how to set, without breaking things. Replace with $null to flush
        $view.update()
        $ctx.ExecuteQuery()
    }
