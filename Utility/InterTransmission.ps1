#InterTransmission GUI
$targetTitle = ""
add-type -assemblyname system.windows.forms
Add-Type -AssemblyName System.Drawing

$Form = new-object system.windows.forms.form
$Form.text = "Intertransmission"
$form.width=500

$TargetLbl = new-object System.Windows.Forms.Label
$TargetLbl.width=450
$TargetLbl.Height=20
$TargetLbl.left=10
$TargetLbl.top=10
$TargetLbl.text="Enter or select the name of the target window. This is effectively a startswith search"

$TargetCombo = new-object System.Windows.Forms.TextBox
$TargetCombo.width=350
$TargetCombo.Height=20
$TargetCombo.left=10
$TargetCombo.top=30

$TextEntryLbl = new-object System.Windows.Forms.Label
$TextEntryLbl.width=450
$TextEntryLbl.Height=20
$TextEntryLbl.left=10
$TextEntryLbl.top=60
$TextEntryLbl.text="Enter text in field below and click button to submit"

$TextTb = new-object System.Windows.Forms.TextBox
$TextTb.width=350
$TextTb.Height=20
$TextTb.left=10
$TextTb.top=80

$dragover = [System.Windows.Forms.DragEventHandler]{
            $_.Effect = 'Copy';  
        
}
$dragdrop = [System.Windows.Forms.DragEventHandler]{
    if($targetCombo.text -ne ""){
		foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) # $_ = [System.Windows.Forms.DragEventArgs]
		{
			intertransmission-sendfile -file $filename -windowTitle $TargetCombo.text
		}
	}
	else{
		[System.windows.forms.messagebox]::Show("Please enter a window title first")
	}
}
$transmit = {
    if($targetCombo.text -ne ""){
		write-host $TextTB.Text
		write-host $TargetCombo.text
        intertransmission-sendText -text $TextTB.Text -windowTitle $TargetCombo.text
    }
	else{
		[System.windows.forms.messagebox]::Show("Please enter a window title first")
	}
}

$DragDropLbl = new-object System.Windows.Forms.label
$dragdroplbl.autosize=$false
$DragDropLbl.width=450
$DragDropLbl.Height=60
$DragDropLbl.BackColor = [System.Drawing.Color]::Red
$dragdropLbl.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$DragDropLbl.left=10
$DragDropLbl.top=130
$dragdroplbl.text = "Dragdrop a file here AFTER SETTING THE TARGET to transmit it's contents. This only understands text files (.txt, .bat, .ps1, .csv) and will choke on pretty much anything else"
$dragdroplbl.textalign = [System.Drawing.ContentAlignment]::MiddleCenter
$DragDropLbl.AllowDrop = $true

$SendTextbtn = new-object System.Windows.Forms.Button
$SendTextbtn.width=80
$SendTextbtn.Height=20
$SendTextbtn.left=380
$SendTextbtn.top=80
$SendTextbtn.text="Send"

$DragDropLbl.add_dragenter($dragover)
$DragDropLbl.add_dragdrop($dragdrop)
$SendTextbtn.add_click($transmit)

$form.controls.add($targetlbl)
$form.controls.add($DragDropLbl)
$form.controls.add($TextEntryLbl)
$form.controls.add($TargetCombo)
$form.controls.add($SendTextbtn)
$form.controls.add($TextTb)

#Takes a text file (utf8 encoded) and sends it as keyboard input to the specified window
function intertransmission-sendFile{
    param(
       $file = (read-host "Enter the file path of the file to transmit"),
       $windowTitle = (read-host "Enter the name of the window you'd like to send the output to")
    )
    $ReplacementArray = @(
	    @('{',":&Open:"),
	    @('}',":&Close:"),
	    @('+',"{+}"),
	    @('^',"{^}"),
	    @('%',"{%}"),
	    @('~',"{~}"),
	    @('(',"{(}"),
	    @(')',"{)}"),
	    @(':&Open:',"{{}"),
	    @(':&Close:',"{}}")
    )
    $fileContent = gc $file -encoding Utf8
    foreach($replacement in $replacementarray){
	    $fileContent = $fileContent.replace($replacement[0], $replacement[1])
    }
    $wshell = New-Object -ComObject wscript.shell;
    $wshell.AppActivate($windowTitle)
    Sleep 2
    $fileContent | %{$wshell.SendKeys($_+"~")}
    Sleep 2
}
#Takes text and sends it as keyboard input to the specified window
function intertransmission-sendText{
    param(
       $text = (read-host "Enter the text to transmit"),
       $windowTitle = (read-host "Enter the name of the window you'd like to send the output to")
    )
	write-host $text
	write-host $windowTitle
    $ReplacementArray = @(
	    @('{',":&Open:"),
	    @('}',":&Close:"),
	    @('+',"{+}"),
	    @('^',"{^}"),
	    @('%',"{%}"),
	    @('~',"{~}"),
	    @('(',"{(}"),
	    @(')',"{)}"),
	    @(':&Open:',"{{}"),
	    @(':&Close:',"{}}")
    )
    foreach($replacement in $replacementarray){
	    $text = $text.replace($replacement[0], $replacement[1])
    }
    $wshell = New-Object -ComObject wscript.shell;
    $wshell.AppActivate($windowTitle)
    Sleep 2
    $text | %{$wshell.SendKeys($_+"~")}
    Sleep 2
}


$form.ShowDialog()
