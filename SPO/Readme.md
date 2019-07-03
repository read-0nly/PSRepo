# SPO #

### FixListViewNewDocumentTemplates ##
A fix to a very specific bug. Let's say you have a doclib, and you click the "New" button, and there's no file types available. So you click "Edit New Menu" to go check the filetypes you need to be able to create, to discover that there's no files available here either.

The reason this happens is a property of the view, called NewDocumentTemplates - the value of it looks something like this:
>[{"title":"Folder","visible":true},{"title":"Word document","visible":false},{"title":"Excel workbook","visible":true},{"title":"PowerPoint presentation","visible":true},{"title":"OneNote notebook","visible":true},{"title":"Forms for Excel","visible":true}]
    
So, this property can have a few different values. It can be null, it can be empty, or it can be formatted as above. And each file type therefore has 4 possible states - null (because the whole thing is null), missing, included with visible true, included with visible false.

If the property is null, it just uses the default (basically, all file types available)

If the property has a value, but one isn't listed (say, "Word document"), that file type is not available nor can it be added using the Edit New Menu pane (so you can't check the box next to "Word Document" to add it back)

If the filetype is unchecked in the Edit New Menu pane, it remains listed, but visible is set to false

So what happens if the value is not null, but rather empty?

So this script sets the template to itself, because it was meant to document the fix when I figured it out. Swap out the self-reference in that line with null and you have a fix for the issue

### List Permission Mapper ##
Maps out the permissions set throughout a list or document library recursively
