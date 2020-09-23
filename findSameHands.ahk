#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

inputFolder := "C:\findSameHandsInput"
hand_a := {}, hand_a.fullString := [], hand_a.ID := []
hand_b := {}, hand_b.fullString := [], hand_b.ID := []
amountOfSymBeforeID := 11, IDLen := 12
hand_a1 := [], hand_a2 := [], hand_a1_2 := []
hand_b1 := [], hand_b2 := [], hand_b1_2 := []
hand_a1_string := [], hand_a2_string := [], hand_b1_2_string := [], hand_b2_string := [], hand_b1_string := [], hand_a1_2_string := []

\::
    timesA := 0
    timesB := 0
    createInputFoldersIfNotExists(inputFolder)
    deleteFilesWarning()

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
    
    createStringFromArray("hand_a1", hand_a1)
    createStringFromArray("hand_a2", hand_a2)
    createStringFromArray("hand_b1_2", hand_b1_2)
    createStringFromArray("hand_b2", hand_b2)
    createStringFromArray("hand_b1", hand_b1)
    createStringFromArray("hand_a1_2", hand_a1_2)

    createNewFiles()


    dir_a1 = %inputFolder%\a1.txt
    dir_a2 = %inputFolder%\a2.txt
    dir_b1 = %inputFolder%\b1.txt
    dir_b2 = %inputFolder%\b2.txt

    nmA1Hands := hand_a1.Length()
    nmA2Hands := hand_a2.Length()
    nmB1Hands := hand_b1_2.Length()
    nmB2Hands := hand_b2.Length()
    nmB1TestHands := hand_b1.Length()
    nmA1TestHands := hand_a1_2.Length()
    if (nmA1Hands != nmB1Hands)
        MsgBox, WARNING amonut of hands in a1 isnt the same as b1.`nClick OK to continue...
    else if (nmA1Hands != nmB1TestHands || nmA1Hands != nmA1TestHands || nmA1TestHands != nmB1TestHands)
        MsgBox, Error nmA1Hands != nmB1TestHands || nmA1Hands != nmA1TestHands || nmA1TestHands != nmB1TestHands

    MsgBox, read %timesA% files in%inputFolder%\a`nread %timesB% files in %inputFolder%\b`n`ncreated files:`n%dir_a1% - %nmA1Hands%`n%dir_a2% - %nmA2Hands%`n%dir_b1% - %nmB1Hands%`n%dir_b2% - %nmB2Hands%
return

ESC::
	ExitApp
return
;test delte thsi message
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
    global hand_a1, hand_a, hand_b1, hand_b2, hand_a1_2, hand_b1_2
    array_a1 = %hand1%1
    array_a2 = %hand1%2
    array_2 = %hand2%1_2

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
            %array_2%.Push(%hand2%.fullString[j])
        }
        else
            %array_a2%.Push(%hand1%.fullString[i])
    }

    totalGames := %hand1%.fullString.Length()
    sumLengthArray1Array2 := %array_a1%.Length() + %array_a2%.Length()
    if (sumLengthArray1Array2 != totalGames)
        MsgBox, putSameHandsAndDifHandsInSepArrays func
}

createNewFiles(){
    global hand_a1_string, hand_a2_string, hand_b1_2_string, hand_b2_string, inputFolder

    dir_a1 = %inputFolder%\a1.txt
    dir_a2 = %inputFolder%\a2.txt
    dir_b1 = %inputFolder%\b1.txt
    dir_b2 = %inputFolder%\b2.txt

    deleteFilesWarning()

    appendArrayToFile(hand_a1_string, dir_a1)
    appendArrayToFile(hand_a2_string, dir_a2)
    appendArrayToFile(hand_b1_2_string, dir_b1)
    appendArrayToFile(hand_b2_string, dir_b2)
}
appendArrayToFile(array, dir){

    length := array.Length()
    for i, element in array{
        FileAppend, %element%, %dir%
        if (length != i)
            FileAppend, "`n`n`n", %dir%
    }
}

deleteFilesWarning(){
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
}

createStringFromArray(arrayName, array){
    array := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]

    stringArrayName = %arrayName%_string
    %stringArrayName% := []

    string := ""
    length := array.Length()
    i := 1
    while (i <= length){
        arrayElString := array[i]
        string = %string%`n`n`n%arrayElString%
        i++
        notDivFromThous := Mod(i, 1000)
        if (notDivFromThous = 0 && i <= length){
            string := SubStr(string, 4)
            %stringArrayName%.Push(string)
            string := ""
        }
    }

    string := SubStr(string, 4)
    %stringArrayName%.Push(string)
    string := ""

    global hand_a1_string := %stringArrayName%
}
