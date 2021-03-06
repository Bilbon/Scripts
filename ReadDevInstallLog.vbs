Const ForReading = 1, ForWriting = 2, ForAppending = 8
Set objFSO = CreateObject("Scripting.FileSystemObject")
strlogPath = "F:\ssdh1\setupapi.dev.log"
outlogPath = "F:\ssdh2outlog.csv"
Set objlogFile = objFSO.OpenTextFile(strlogPath, 1, False)
Set objoutlogFile = objFSO.CreateTextFile(outlogPath, True)

cnt = 0
objoutlogFile.Write "Order Install,Device Name,Start,End" & vbCrLf
Do Until objlogFile.AtEndOfStream
	strLine = objlogFile.ReadLine
	If InStr(strLine, ">>>  [") Or InStr(strLine, "<<<  Section end") Or InStr(strLine, ">>>  Section start") AND InStr(strLine, "[Setup Plug and Play Device Install]") = 0 Then
			strLine = Replace(strLine, "<<<  ", "")
			strLine = Replace(strLine, ">>>  ", "")
			If InStr(strLine, "\") Then
				cnt = cnt +1
				strOut = cnt & "," & strLine
			ElseIf InStr(strLine, "Section start") Then
				If Not strOut = "" Then
					strOut = strOut & "," & Mid(strLine, InStr(strLine, "/08")+4, 5)
				End If
			ElseIf InStr(strLine, "Section end") Then
				If Not strOut = "" Then
					strOut = strOut & "," & Mid(strLine, InStr(strLine, "/08")+4, 5)
				End If
			End If
	
			If InStr(strLine, "Section end") Then
				If Len(strOut) > 2 Then
					objoutlogFile.Write strOut & vbCrLf
					strOut = ""
				End If
			End If
	End If
Loop

objoutlogFile.Close
objlogFile.Close
