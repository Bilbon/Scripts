'==================================================================================
' NAME: Prep_Drivers.vbs
'
' AUTHOR: Brian Gonzalez, PSCNA
' DATE  : Feb 04, 2013
'
' COMMENT: Preps drivers downloaded for use with "Install.exe" bundle installer.
'==================================================================================
On Error Resume Next
'Setup common objects
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject("WScript.Shell")
sFolderLength = 35
'Populate var with current directory
sScriptFolder = oFSO.GetParentFolderName(Wscript.ScriptFullName) 'No trailing backslash
Set oScriptFolder = oFSO.GetFolder(sScriptFolder)
Set cScriptSubFolders = oScriptFolder.SubFolders

'Grab Sub-Folder Name where Driver .ZIPs exist
If cScriptSubFolders.Count > 1 Then WScript.Echo "Too many Sub-Folders exist in Script Directory, " &_
	"Only one should exist containing .ZIPs for each driver install.", WScript.Quit

'Grab Sub-Folder path into var
For Each sSubFolder In cScriptSubFolders
	sDriverParentFolder = sSubFolder.Path
Next

'Set ScriptFolder as Current for batch file processing (7za.exe)
oShell.CurrentDirectory = sScriptFolder
s7ZipPath = sScriptFolder & "\7za.exe"

'Check for 7Zip.exe in Script Dir
If NOT oFSO.FileExists(s7ZipPath) Then Wscript.Echo "7zip was not found (Can be downloaded from http://www.7-zip.org/download.html)." & vbCrLf &_
	"Please place file in the following location: " & s7ZipPath, Wscript.Quit
'Check for src subfolder in Script Dir
If NOT oFSO.FolderExists(sDriverParentFolder) Then Wscript.Echo "SRC folder was not found. Please place file in the following location: " & sDriverParentFolder, Wscript.Quit

'Check for PInstall.bat files in all Driver sub-Folders
sMissingCount = 0
Set oDriverParentFolder = oFSO.GetFolder(sDriverParentFolder)
For Each oDrvFol In oDriverParentFolder.SubFolders
	'Populate a sMessage with Driver Folders not containing PInstall.bat files.
	If Not oFSO.FileExists(oDrvFol.path & "\pinstall.bat") AND Not LEFT(oDrvFol.name, 2) = "##" Then
		
		sMissingPInstallPrompt = sMissingPInstallPrompt & vbCrlf & oDrvFol.name & "'s ""pinstall.bat"" does not exist."
		sMissingCount = sMissingCount + 1
	End If
Next

'Display Prompt for Missing PInstalls
If sMissingCount > 0 Then Wscript.Echo sMissingPInstallPrompt, Wscript.Quit

'Rename and Remove Strings from Driver Folder Names.
Set oDriverParentFolder = oFSO.GetFolder(sDriverParentFolder)
For Each oDrvFol In objDriverParentFolder.SubFolders
		'Remove from Folder Name grouping
		sNewDrvFolderName = Replace(oDrvFol.name, "[", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "]", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, " ", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Utility", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Util", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Manager", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "MgrApp", "")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "%", "")
				
		'Replace from Folder Name grouping
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Panasonic", "Pna")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Technology", "Tech")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Components", "Cmp")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Driver", "Drv")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "(", "_")
		sNewDrvFolderName = Replace(sNewDrvFolderName, ")", "_")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "System", "Sys")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Interface", "Int")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Fingerprint", "Fngr")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Bluetooth", "BT")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Recalibration", "Recal")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "Calibration", "Cal")
		sNewDrvFolderName = Replace(sNewDrvFolderName, "__", "_")
		sNewDrvFolderName = Left(sNewDrvFolderName, sFolderLength)
		
		'Perform Folder Name change
		oFSO.MoveFolder oDrvFol.path, sDriverParentFolder & "\" & sNewDrvFolderName
Next

'Pop-Up Window Prior To Kicking Off Install
oShell.Popup "Processing of names and verification of content is complete.  Compression of Driver Folders will now begin.", 5, "Processing Prompt..."

'Begin Compressing Folders to zip files
Set oDriverParentFolder = oFSO.GetFolder(sDriverParentFolder)
For Each oDrvFol In oDriverParentFolder.SubFolders
		sCmd = "cmd /c 7za.exe a "".\src\" & oDrvFol.Name & ".zip"" "".\src\" & oDrvFol.name & "\*"""
		intReturn = oShell.Run(sCmd, 3, True)
		Wscript.Sleep 1000

		If intReturn = 0 Then
			oFSO.DeleteFolder oDrvFol.path
			sCmd = "cmd /c rd /s /q """ & oDrvFol.path & """"
			intReturn = oShell.Run(sCmd, 3, True)
		Else
			WScript.Echo "Error when compressing folder: " & oDrvFol.path & ", exiting script"
			WScript.Quit
		End If
Next

'Rename "src" folder to Bundle Name folder.
Set oScriptFolder = oFSO.GetFolder(sScriptFolder)
i = "0"
Do Until i = "1"
	sAnswer = InputBox("Bundle Name?", "", oScriptFolder.Name)
	'Perform "src" Folder Name change
	If Trim(sAnswer) <> "" And sAnswer <> "-1" Then
		oFSO.MoveFolder oDriverParentFolder.path, oScriptFolder.path & "\" & sAnswer
		i = "1"
	End If
Loop

Wscript.Echo "Script is Complete processing " & sScriptFolder & ", copy install.exe into this folder to complete package."

' Delete itself and 7zip.exe
oFSO.DeleteFile WScript.ScriptFullName, True
oFSO.DeleteFile s7ZipPath, True
