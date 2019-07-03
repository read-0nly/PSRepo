# SPO #

### FixListViewNewDocumentTemplates ##
A fix to a very specific bug. Let's say you have a doclib, and you click the "New" button, and there's no file types available. So you click "Edit New Menu" to go check the filetypes you need to be able to create, to discover that there's no files available here either.

The reason this happens is a property of the view, called NewDocumentTemplates - the value of it looks something like this:
[{"title":"Folder","visible":true},{"title":"Word document","visible":true},{"title":"Excel workbook","visible":true},{"title":"PowerPoint presentation","visible":true},{"title":"OneNote notebook","visible":true},{"title":"Forms for Excel","visible":true}]
    
