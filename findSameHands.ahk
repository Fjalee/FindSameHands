#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

inputFolder := "C:\findSameHandsInput"
hand_a := {}, hand_a.fullString := [], hand_a.ID := []
hand_b := {}, hand_b.fullString := [], hand_b.ID := []
amountOfSymBeforeID := 11, IDLen := 12

;fix 
;final message
;input so that can input from folders a and b

\::
    timesA := 0
    timesB := 0
    createInputFoldersIfNotExists(inputFolder)

    MsgBox, After pressing OK the conversion will begin...
    Loop Files, %inputFolder%\a\*.txt
    { 
        timesA++

        tempFunc("a", A_LoopFileName)
    }
    Loop Files, %inputFolder%\b\*.txt
    {
        timesB++

        tempFunc("b", A_LoopFileName)
    }

    separateID("hand_a")
    separateID("hand_b")

    MsgBox, read %timesA% files in%inputFolder%\a`nread %timesB% files in %inputFolder%\b`ncreated 

return

ESC::
	ExitApp
return

createInputFoldersIfNotExists(fileDir){
    if !FileExist(fileDir){
        FileCreateDir, %fileDir%
        FileCreateDir, %fileDir%\a
        FileCreateDir, %fileDir%\b
        MsgBox, created directory %fileDir%`n and folders a and b in the directory`nEXITING SCRIPT

        ExitApp
    }
}

input(fileDir){
    FileRead, inputString, %fileDir%
    return inputString
}

tempFunc(a_or_b, loopFileName){
    global inputFolder
    if (a_or_b = "a")
        hand := "hand_a"
    else if (a_or_b = "b")
        hand := "hand_b"

    fileDir = %inputFolder%\%a_or_b%\%loopFileName%
    inputString := input(fileDir)

    newLineKind := checkWhichKindNewLine(inputString)
    splitTextIntoObjects(inputString, newLineKind, hand)

}
checkWhichKindNewLine(inputString){
    nrFound := 0
    nFound := 0
    nr := "`n`r`n`r`n"
    n := "`n`n`n"
    IfInString, inputString, %nr%
        nrFound := 1
    IfInString, inputString, %n%
        nFound := 1

    if (nrFound && nFound)
        MsgBox, Error func checkWhichKindNewLine, both kind of newlines
    else if (nrFound)
        return "`n`r`n`r`n"
    else if (nFound)
        return "`n`n`n"
    else if (!nFound && !nrFound)
        MsgBox, Error func checkWhichKindNewLine, Cant find double newline
}
splitTextIntoObjects(inputString, newLineKind, objectName){
    global hand_a, hand_b
    gamesFullStringsArray := StrSplit(inputString, newLineKind)
    lastItem := gamesFullStringsArray.Pop()
    if (lastItem != "")
        MsgBox, Error splitTextIntoObjects(), last item isnt blank
    
    for i, element in gamesFullStringsArray{
        %objectName%.fullString.Push(element)
    }

    if (gamesFullStringsArray.Length() < 1){
        MsgBox, Error func splitTextIntoObjects, no double newline found`nEXITING SCRIPT
        ExitApp
    }
}

separateID(hand){
    global hand_a, hand_b, amountOfSymBeforeID, IDLen
    
    for i, element in %hand%.fullString{
        ID := SubStr(element, amountOfSymBeforeID+1, IDLen)
        %hand%.ID.Push(ID)

        SymBefore := SubStr(element, amountOfSymBeforeID, 1)
        SymAfter := SubStr(element, amountOfSymBeforeID+amountOfSymBeforeID+2, 1)
        if (SymBefore != " " || SymAfter != ":")
            MsgBox, Error separateID()
    }
}








;fixxx
rewriteFile(fileDir, newText){
    FileDelete, %fileDir%
    FileAppend, %newText%, %fileDir%
}

