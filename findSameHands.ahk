#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

inputFolder := "C:\findSameHandsInput"
hand_a := {}, hand_a.fullString := [], hand_a.ID := []
hand_b := {}, hand_b.fullString := [], hand_b.ID := []
amountOfSymBeforeID := 11, IDLen := 12
hand_a1 := [], hand_a2 := []
hand_b1 := [], hand_b2 := [], hand_b2test := []

\::
    timesA := 0
    timesB := 0
    createInputFoldersIfNotExists(inputFolder)

    MsgBox, After pressing OK the conversion will begin...
    Loop Files, %inputFolder%\a\*.txt
    { 
        timesA++

        mainForA_or_B("a", A_LoopFileName)
    }
    Loop Files, %inputFolder%\b\*.txt
    {
        timesB++

        mainForA_or_B("b", A_LoopFileName)
    }

    separateID("hand_a")
    separateID("hand_b")

    putSameHandsAndDifHandsInSepArrays("hand_a", "hand_b")
    putSameHandsAndDifHandsInSepArrays("hand_b", "hand_a")

    a1String := createStringFromArray(hand_a1)
    a2String := createStringFromArray(hand_a2)
    b1String := createStringFromArray(hand_b1)
    b2String := createStringFromArray(hand_b2)

    createNewFiles(a1String, a2String, b1String, b2String)


    dir_a1 = %inputFolder%\a1.txt
    dir_a2 = %inputFolder%\a2.txt
    dir_b1 = %inputFolder%\b1.txt
    dir_b2 = %inputFolder%\b2.txt

    nmA1Hands := hand_a1.Length()
    nmA2Hands := hand_a2.Length()
    nmB1Hands := hand_b1.Length()
    nmB2Hands := hand_b2.Length()
    MsgBox, read %timesA% files in%inputFolder%\a`nread %timesB% files in %inputFolder%\b`n`ncreated files:`n%dir_a1% - %nmA1Hands%`n%dir_a2% - %nmA2Hands%`n%dir_b1% - %nmB1Hands%`n%dir_b2% - %nmB2Hands%
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

mainForA_or_B(a_or_b, loopFileName){
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

putSameHandsAndDifHandsInSepArrays(hand1, hand2){
    global hand_a, hand_b, 
    global hand_a1, hand_a, hand_b1, hand_b2, hand_b2test
    array_a1 = %hand1%1
    array_a2 = %hand1%2

    for i, element_i in %hand1%.ID{
        broke := 0

        for j, element_j in %hand2%.ID{
            if (element_i = element_j){
                broke := 1
                break
            }
        }
        if (broke){
            %array_a1%.Push(%hand1%.fullString[i])
        }
        else
            %array_a2%.Push(%hand1%.fullString[i])
    }

    totalGames := %hand1%.fullString.Length()
    sumLengthArray1Array2 := %array_a1%.Length() + %array_a2%.Length()
    if (sumLengthArray1Array2 != totalGames)
        MsgBox, putSameHandsAndDifHandsInSepArrays func
}

createNewFiles(a1String, a2String, b1String, b2String){
    global inputFolder

    dir_a1 = %inputFolder%\a1.txt
    dir_a2 = %inputFolder%\a2.txt
    dir_b1 = %inputFolder%\b1.txt
    dir_b2 = %inputFolder%\b2.txt
    
    errorMsg := 0
    if FileExist(dir_a1)
        errorMsg := 1
    if FileExist(dir_a2)
        errorMsg := 1
    if FileExist(dir_b1)
        errorMsg := 1
    if FileExist(dir_b2)
        errorMsg := 1
    
    if (errorMsg)
        MsgBox, ERROR, remove files`n%dir_a1%`n%dir_a2%`n%dir_b1%`n%dir_b2%

    FileAppend, %a1String%, %dir_a1%
    FileAppend, %a2String%, %dir_a2%
    FileAppend, %b1String%, %dir_b1%
    FileAppend, %b2String%, %dir_b2%
}

createStringFromArray(array){
    string := ""
    for i, element in array{
        string = %string%`n`n`n%element%
    }
    string := SubStr(string, 4)
    return string
}
