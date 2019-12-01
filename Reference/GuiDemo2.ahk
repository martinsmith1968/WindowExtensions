Gui, Add, Text,, First name:
Gui, Add, Text,, Last name:
Gui, Add, Edit, vFirstName ym  ; The ym option starts a new column of controls.
Gui, Add, Edit, vLastName
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.
MsgBox You entered "%FirstName% %LastName%".
ExitApp
