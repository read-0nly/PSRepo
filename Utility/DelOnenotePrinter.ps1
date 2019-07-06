get-printer |% {if($_.name -eq "Send To OneNote 2016"){rundll32 printui.dll,PrintUIEntry /dl /n "Send To OneNote 2016"}else{echo ($_.name + " is not a match")}}
