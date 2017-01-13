;
; Version:				1.2
; Language:       		English
; Platform:       		Win 10
; Author:         		SGT-Morre
; Date:					2016-01-07	
;
; Script Function:
;
; This script loops every (10) seconds to determine if a specific game is running or not, and set NVIDIAs digital vibrance if it is.
;

iniFile := "settings.ini"

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#Include Class_NvAPI.ahk

ApplicationName := "Digital Vibrance Control (DVC) Settings"

; ================ Tray Options ===========================
Menu, Tray, Icon, imageres.dll, 105 ; more info here: http://www.digitalcitizen.life/where-find-most-windows-10s-native-icons
Menu, Tray, Tip, % ApplicationName
Menu, Tray, NoStandard ; Remove all standard menu items from the tray menu
Menu, Tray, Add, Exit, ExitSub
; =============== END Tray Options =======================

Gui, Add, Tab, x11 y6 w350 h385 vTabs, New|Edit or Delete|Set Default DV|Reset


;======= GET GAMES =======

game_path_arr := Object()
i := 0
Loop, Read, %A_ScriptDir%\games.txt ; This loop retrieves each line from the file, one at a time.
{
    game_path_arr.Insert(A_LoopReadLine) ; Append this line to the array.
	++i
}

;====== END GET GAMES ============

;========= SET DEFOUT TAB ===============


;=========== END ===================

;============ NEW TAB ===========
Gui, Tab, 1, 1

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, GroupBox, xm+10 y+5 w315 h110, % "Add new Games and set Digital Vibrance"
;Gui, Add, Text, x30 y35 w200 h13, Add new games

IniRead, boxValue, %iniFile%, ComboBox, games, bf1.exe
Gui, Add, ComboBox, x30 y73 w250 vNEW_GAME_PATH, %boxValue%
Gui, Add, Text, x30 y55 w60 h13, Game exe file
Gui, Add, Edit,x296 y73 w25 h21 Number Limit3 vNEW_GAMEDVC, 70
Gui, Add, Text, x297 y56 w21 h13, DV
Gui, Add, Button, x30 y107 w43 h23 gADDNew, Add
Gui, Add, Button, x77 y107 w43 h23 gResetComboBox, Reset
Gui, Add, Button, x123 y107 w43 h23 gNeedHelp, Help

Gui, Add, GroupBox, xm+10 y150 w315 h70, % "Functions"
Gui, Add, Button, xm+15 y172 w100 h36 gStart, Start
Gui, Add, Button, xm+117 y172 w100 h36 gSetOnStartUp, Add to StartUp
Gui, Add, Button, xm+219 y172 w100 h36 gRemoveFromStartup, Remove from startup

displayNum := 0
while (NvAPI.EnumNvidiaDisplayHandle(displayNum) != "*-7") {
    ++displayNum
}

;MsgBox %displayNum%
;return

gbh := 45 + 27 * (displayNum - 1)

Gui, Add, GroupBox, xm+10 yp+50 w315 h%gbh%, % "Select Display(s) you play on"

;IniRead, OutputVar, %iniFile%, Games, Key [, Default]
;IniWrite, Value, %iniFile%, Games, Key
;IniDelete, %iniFile%, Games [, Key]
loop % displayNum {
	IniRead, checkdDisplays, %A_ScriptDir%\settings.ini, Displays, display%A_Index%, 0
	Gui, Add, CheckBox, x30 yp+20 w120 h15 Checked%checkdDisplays% vDISPLAYNUM%A_Index%, % "Display #" . A_Index . ""
}
Gui, Add, Button, xm+219 y240 w100 h23 gSelectDisplay, Select
;=========== END NEW TAB =================



;=========== EDIT TAB =================
Gui, Tab, 2, 1

indexH := 92 + 25 * (i - 1)
Gui, Add, GroupBox, xm+10 ym+30 w335 h%indexH%, % "Delete from this app"

Gui, Add, Text, xm22 ym+50 w80 h13, Game exe file
Gui, Add, Text, x267 ym+50 w21 h13, DV

;IniRead, OutputVar, %iniFile%, Games, Key [, Default]
;IniWrite, Value, %iniFile%, Games, Key
;IniDelete, %iniFile%, Games [, Key]
i = 0
for index, game_path in game_path_arr {
	IniRead, game_DV, %iniFile%, Games, %game_path%, 50
	
	Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
	Gui, Add, Edit, xm22 yp+20 w220 h21 ReadOnly vPATH%index%, % game_path
	Gui, Add, Edit, x263 yp w27 h21 vGAMEDVC%index%, % game_DV
	
	Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
	;Gui,Add,Radio, x303 yp+5 w50 h13 vDELETE%index%, % "(" . index . ")"
	Gui, Add, CheckBox, x303 yp+5 w50 h13 vDELETE%index%, % "(" . index . ")"
	;Gui, Add, Button, x297 yp-2 w50 vDELETE%index% gDELETE, % "Delete"
	++i
}

Gui, Add, Button, xm22 yp+20 w43 h23 gDELETE, Delete
Gui, Add, Button, x86 yp w43 h23 gEDIT, Edit
;============== END EDIT TAB ======================

;============== SET DV TAB =====================
Gui, Tab, 3, 1

cnt := 0, arrCur := [], arrDef := []

while (NvAPI.EnumNvidiaDisplayHandle(cnt) != "*-7")
{
    arrCur.Insert(NvAPI.GetDVCInfoEx(cnt).currentLevel)
    arrDef.Insert(NvAPI.GetDVCInfoEx(cnt).defaultLevel)
    ++cnt
}

gbh := 93 + 27 * (cnt - 1)

Gui, Font, s18 w800 q4 c76B900, MS Shell Dlg 2
Gui, Add, Text, xm ym+25 w240 0x201, % NvAPI.GPU_GetFullName()

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, GroupBox, xm+10 y+10 w240 h%gbh%, % "Digital Vibrance Control (DVC)"

Gui, Add, Text, xm+21 ym+85 w60 h22 0x0200, % "Display #1"
Gui, Add, Edit, x+10 yp w80 h22 0x2002 Limit3 vDVCS1, % arrCur[1]
Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
Gui, Add, Text, x+10 yp w60 h22 0x0200, % "(0 - 100)"

loop % arrCur.MaxIndex() - 1
{
    cur := A_Index + 1
    Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
    Gui, Add, Text, xm+21 y+5 w60 h22 0x0200, % "Display #" cur
    Gui, Add, Edit, x+10 yp w80 h22 0x2002 Limit3 vDVCS%cur%, % arrCur[cur]
    Gui, Font, s9 w400 q1 csilver, MS Shell Dlg 2
    Gui, Add, Text, x+10 yp w60 h22 0x0200, % "(0 - 100)"
}

Gui, Add, Button, xm+20 y+10 w60 gDVCSet, % "Set"
Gui, Add, Button, x+20 yp w60 gDVCReset, % "Reset"

; ================= END SET DV TAB ===========================

; =============== FACTORY RESET ========================
Gui, Tab, 4, 1
Gui, Font, s14 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, Text, xm+105 y+90 w160 h50, Reset Settings
Gui, Add, Button, xm+90 y150 w150 h56 gFactoryReset, Reset

; ================END========================

Gui, Show, AutoSize, % (GuiTitle := ApplicationName)


return

;IniRead, OutputVar, %iniFile%, Games, Key [, Default]
;IniWrite, Value, %iniFile%, Games, Key
;IniDelete, %iniFile%, Games [, Key]

ADDNew:
	Gui, Submit, NoHide
	
	if (NEW_GAME_PATH = "") {
		MsgBox Add a .exe file for me to save
		return
	}
	
	dvc := NEW_GAMEDVC
	
	if (dvc > 100 or dvc < 1) {
		dvc = 100
	}
	
	Loop, Read, %A_ScriptDir%\games.txt 
		if (NEW_GAME_PATH == A_LoopReadLine) {
			MsgBox, %NEW_GAME_PATH% already exists
			
			
			Reload
			return
		}
	
	;Check if it exists
	IniRead, boxValue, %iniFile%, ComboBox, games, bf1.exe
	if (!RegExMatch(boxValue, NEW_GAME_PATH, SubPat)) {
		if (boxValue == "")
			boxValue := % NEW_GAME_PATH
		else
			boxValue := % boxValue . "|" . NEW_GAME_PATH
		
		IniWrite, %boxValue%, %iniFile%, ComboBox, games
		;MsgBox Japp den är tillagd
		;Reload
		;return
	}
	
	IniWrite, %dvc%, %iniFile%, Games, %NEW_GAME_PATH%
	
	;FileAppend, %dvc% %NEW_GAME_PATH%`n, %A_ScriptDir%\games.txt
	FileAppend, %NEW_GAME_PATH%`n, %A_ScriptDir%\games.txt
	
	MsgBox %NEW_GAME_PATH% is Added
	

	Reload
return

ResetComboBox:
	MsgBox, 4, , Would you like to reset ComboBox? 
	IfMsgBox, Yes
		IniWrite, "", %iniFile%, ComboBox, games
	
	Reload
return

DELETE:
	Gui, Submit, NoHide
		
	game_path_arr := Object()
	i := 0
	Loop, Read, %A_ScriptDir%\games.txt ; This loop retrieves each line from the file, one at a time.
	{
		game_path_arr.Insert(A_LoopReadLine) ; Append this line to the array.
		++i
	}
	
	
	delMe := Object()
	loop, %i%
        if ( DELETE%A_Index% ) {
			delMe.Insert(A_Index)
        }

	if (delMe.Length() == 0)
	{
		;MsgBox Ja detta händer
		return
	}

	if (delMe.Length() == game_path_arr.Length()) {
		MsgBox, 4,, Delete all games from DVC script?
		IfMsgBox No
			return
			
		FileDelete %A_ScriptDir%\games.txt
		IniDelete, %iniFile%, Games
		
		Reload
		return
	}
	
	
		
	delMeText := Object()
	for k,v in delMe {
		IniDelete, %iniFile%, Games, % game_path_arr[v]
		;delMeText.Insert(StrSplit(game_path_arr[v], " ", ", `t")[2])
		delMeText.Insert(game_path_arr[v])
	}	
	;delMeText := StrSplit(game_path_arr[delMe], " ", ", `t")[2]
	output := arrayToString(delMeText, ", ")
	MsgBox, 4,, Delete %output% from DVC script?
	IfMsgBox No
		return
	
	Loop, Read, %A_ScriptDir%\games.txt, %A_ScriptDir%\OutputFile.txt
	if ( inArray(delMe, A_Index) )
		Continue
	else
		FileAppend %A_LoopReadLine%`n
  
	FileMove, %A_ScriptDir%\OutputFile.txt, %A_ScriptDir%\games.txt, 1
	
	Reload
return

EDIT:
	Gui, Submit, NoHide

	o := Object()
	Loop, Read, %A_ScriptDir%\games.txt, %A_ScriptDir%\OutputFile.txt
	{
		;o.Insert(GAMEDVC%A_Index%)
		;o.Insert(" ")
		o.Insert(PATH%A_Index%)
		o.Insert("`n")
		
		gamePath := PATH%A_Index%
		pameDV   := GAMEDVC%A_Index%
		IniWrite, %pameDV%, %iniFile%, Games, %gamePath%
	}
	
	setVal(this) {
		Loop % this.MaxIndex()
			Content .= this[A_Index]
		return Content
	}
	
	o.setVal := Func("setVal")
	FileAppend, % o.setVal(), %A_ScriptDir%\OutputFile.txt
	FileMove, %A_ScriptDir%\OutputFile.txt, %A_ScriptDir%\games.txt, 1
	
return


SelectDisplay:
	Gui, Submit, NoHide
	gameDisplays := Object()
	loop, %displayNum% {
        if ( DISPLAYNUM%A_Index% ) {
			gameDisplays.Insert(A_Index)
			IniWrite, 1, %A_ScriptDir%\settings.ini, Displays, display%A_Index%
        } else {
			IniWrite, 0, %A_ScriptDir%\settings.ini, Displays, display%A_Index%
		}
	}
	if(gameDisplays.Length() == 0) 
		MsgBox No Displays selected
	
return

NeedHelp:
	run process.exe
return

FactoryReset:
	MsgBox, 4, , Would you like to continue? 
	IfMsgBox, Yes 
		ResetMe()
	
	Goto GuiEscape
return

ResetMe() {
	FileMove, %A_ScriptDir%\default.ini, %A_ScriptDir%\settings.ini, 1
	FileCopy, %A_ScriptDir%\settings.ini, %A_ScriptDir%\default.ini, 1
	Filedelete, %A_ScriptDir%\games.txt
	Run setup.exe
}

DVCSet:
    Gui, Submit, NoHide
    loop % arrCur.MaxIndex()
	{
        DVCS := DVCS%A_Index% > 100 ? 100 : DVCS%A_Index% < 0 ? 0 : DVCS%A_Index%
        NvAPI.SetDVCLevelEx(DVCS, A_Index - 1)
        GuiControl,, DVCS%A_Index%, % DVCS
	}
return

DVCReset:
    loop % arrDef.MaxIndex()
    {
        NvAPI.SetDVCLevelEx(arrDef[A_Index], A_Index - 1)
        GuiControl,, DVCS%A_Index%, % arrCur[A_Index]
    }
return

SetOnStartUp:
	;RunWait, %A_WinDir%\System32\schtasks.exe /create /TN [SetDVCOnGames] /TR [%A_ScriptDir%\testGUI.exe] /RL HIGHEST /SC ONLOGON
	;MsgBox Not Working!!!
	appName := "Digital Vibrance for a specific Game"

	MsgBox, 4, %appName%, Would you like this program to start with Windows? (press Yes or No)
	IfMsgBox Yes
	{
		FileCreateShortcut, %A_ScriptDir%\setup.exe, %A_Startup%\%appName%.lnk, %A_ScriptDir% ;create one
		MsgBox,,%appName%, You pressed Yes`n%appName% `nWill start automatically,10
	} ;     MsgBox You pressed Yes.
	else
	{
		Filedelete, %A_Startup%\%appName%.lnk
		MsgBox,,Actioned, You pressed No.`nThis program will not start automatically,10
	}

return

RemoveFromStartup:
	appName := "Digital Vibrance for a specific Game"
	
	MsgBox, 4, %appName%, Would you like to remove this app from startup? (press Yes or No)
	IfMsgBox Yes
	{
		Filedelete, %A_Startup%\%appName%.lnk
		MsgBox,,Actioned, You pressed Yes.`nThis program will not start automatically,10
	} 
	else
	{
		MsgBox,,Actioned, You pressed No.`nGood for you!!!,10
	}
return

Start:
	DetectHiddenWindows, On

	IfWinNotExist, %A_ScriptDir%\setup.exe
		Run, %A_ScriptDir%\setup.exe
		
	ExitApp
return





inArray(haystack, needle) {
    if(!isObject(haystack))
        return false
    if(haystack.Length()==0)
        return false
    for k , v in haystack
        if (v == needle)
            return true
    return false
}

arrayToString(theArray, delimiter := ",")
{
	for key, value in theArray
	{	
		string .= value
		if (theArray.Length() > key)
			string .= delimiter
	}
	
	return string
	;return SubStr(string, 1, StrLen(string)-1)
}

GuiClose:
GuiEscape:
ExitSub:
    ExitApp ; Terminate the script unconditionally
return
Quitter:
ExitApp

