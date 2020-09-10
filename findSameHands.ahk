#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

inputFolder := "C:\findSameHandsInput", outputFolder := "C:\findSameHandsOutput"
game := {}

;fix 
;final message
;input so that can input from folders a and b

\::
    times := 0
    createInputFolderIfNotExists(inputFolder)

    MsgBox, After pressing OK the conversion will begin...
    Loop Files, %inputFolder%\*.txt
    {
        times++

        fileDir = %inputFolder%\%A_LoopFileName%
        inputString := input(fileDir)
    }
    MsgBox, read %times% files in`n%inputFolder%`ncreated 
return

ESC::
	ExitApp
return

createInputFolderIfNotExists(fileDir){
    if !FileExist(fileDir){
        FileCreateDir, %fileDir%
        MsgBox, created directory %fileDir%`n`nEXITING SCRIPT
        ExitApp
    }
}









;fixxx
rewriteFile(fileDir, newText){
    FileDelete, %fileDir%
    FileAppend, %newText%, %fileDir%
}

