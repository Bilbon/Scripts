Set objFSO = CreateObject("Scripting.FileSystemObject")
strPath = "C:\InstallShield 12 Projects\19-1 Win 7 x86"

If objFSO.FileExists(strPath)Then
	WScript.Echo "File Exists returned"
ElseIf objFSO.FolderExists(strPath)Then
	'Set objFile = objFSO.GetFolder(strPath)
	'Wscript.Echo objFile.ShortPath
End If