#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Example #5: Retrieves a list of running processes via COM.



Gui, Add, Text, x10 y15 w250, Search for running Games
Gui, Add, Edit, x10 y30 w250 vSearch
Gui, Add, Button, xm+40 y60 w150 h23 gSearch, Search

Gui, Add, Text, x10 yp30 w250 vResult
Gui, Add, ListBox, x10 yp15 w250 h150 vProcessChoice
Gui, Add, Button, xm+40 yp155 w160 h23 gAddToBoard, Add to Clipboard

GuiControl, Hide, Button2
GuiControl, Hide, ProcessChoice

Gui, Show, AutoSize, Process Search
return


; Win32_Process: http://msdn.microsoft.com/en-us/library/aa394372.aspx
Search:
	Gui, Submit, NoHide
	num := 0
	processName := ""
	q := "SELECT * FROM Win32_Process WHERE Name LIKE '`%" . Search . "`%'"
	for process in ComObjGet("winmgmts:").ExecQuery(q) {
		++num
		processName .= "|" . process.Name
	}
	
	if (num < 1) {
		MsgBox, Nu result
		Reload
	} else {
		GuiControl, Show, Button2
		GuiControl, Show, ProcessChoice
		GuiControl, , Result, Result
		GuiControl, , ProcessChoice, %processName%
		GuiControl, Choose, ProcessChoice, 1
		Gui, Show, AutoSize, Process Search
	}
return


AddToBoard:
	Gui, Submit, NoHide
	Clipboard := ProcessChoice
return


GuiClose:
GuiEscape:
ExitSub:
    ExitApp ; Terminate the script unconditionally
return
Quitter:
ExitApp