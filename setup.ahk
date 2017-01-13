;
; Version:				1.2
; Language:       		English
; Platform:       		Win 10
; Author:         		SGT-Morre
; Date:					2016-01-07	
;
; Script Function:
;
; This script loops every (2) seconds to determine if a specific game is running or not, and set NVIDIAs digital vibrance if it is.
;


iniFile := "settings.ini"

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Class_NvAPI.ahk

ApplicationName := "Sets Digital Vibrance for a specific Game"


; ================ Tray Options ===========================
Menu, Tray, Icon, imageres.dll, 144 ; more info here: http://www.digitalcitizen.life/where-find-most-windows-10s-native-icons
Menu, Tray, Tip, % ApplicationName
Menu, Tray, NoStandard ; Remove all standard menu items from the tray menu
Menu, Tray, Add, Settings, StartSettings
Menu, Tray, Add, Exit, ExitSub
; =============== END Tray Options =======================

cnt := 0, arrCur := [], arrDef := []
sleep_For = 2000


IfNotExist, %A_ScriptDir%\games.txt 
	Goto, NoGameTextFile

;Check the DV level
while (NvAPI.EnumNvidiaDisplayHandle(cnt) != "*-7")
{
	DVLevel := NvAPI.GetDVCInfoEx(cnt).currentLevel
    arrCur.Insert(DVLevel)
    arrDef.Insert(NvAPI.GetDVCInfoEx(cnt).defaultLevel)
    ++cnt
	IniWrite, %DVLevel%, %iniFile%, Displays, displayDef%cnt%
}

game_path_arr	:= Object()
; Write to the array:
loop, Read, %A_ScriptDir%\games.txt ; This loop retrieves each line from the file, one at a time.
{
    game_path_arr.Insert(A_LoopReadLine) ; Append this line to the array.
}

loop {
	for index, game_path in game_path_arr {		
		sleep sleep_For
		
		Process, Exist, %game_path% ; check to see if the game is running
		if (ErrorLevel == 0) { ; If it is not running
			continue
		} else { ; The game is running
			IniRead, game_DV, %iniFile%, Games, %game_path%, 50
			;MsgBox, japp den körs %game_path% %game_DV%
			gameRunning(game_path, game_DV)
		}
	}
}


gameRunning(game_path, game_DV) {
	global arrDef, cnt, sleep_For
	setDVOnDisplays(game_DV) ; Set Dv level for display
	
	; Check if game is running
	loop {
		Process, Exist, %game_path%
		if (ErrorLevel == 0) { ; It is not running anymore
			disp = cnt - 1
			IniRead, DVDefLevel, %iniFile%, Displays, display%disp%, 50
			setDVOnDisplays(DVDefLevel) ; Set Dv level for display
			return
		}
		
		sleep sleep_For
	}
}

setDVOnDisplays(DVLevel) {
	global iniFile
	num := displayNum()
	loop, % num {
		IniRead, checkdDisplays, %iniFile%, Displays, display%A_Index%, 0
		if (checkdDisplays == 1) {
			NvAPI.SetDVCLevelEx(DVLevel, A_Index-1)
		}
	}
}

displayNum() {
	displayNum := 0
	while (NvAPI.EnumNvidiaDisplayHandle(displayNum) != "*-7") {
		++displayNum
	}
	return displayNum
}


return

NoGameTextFile:
	MsgBox, The settings file does not exist. Save settings for me...
	Goto, StartSettings
return

StartSettings:
	Run settings.exe
return

ExitSub:
    ExitApp ; Terminate the script unconditionally
return