###################################################################
# ChangeLog -
# 4/9BG - Added CGMR command to pull Firmware date.
#	- Added WMI call to pull driver version.
###################################################################

$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path

Function fQueryModem($sQueryString, $sRegExp) {
$oComPort = New-Object System.IO.Ports.SerialPort $sComPortNumber,$sComPortSpeed,None,8,1
$oComPort.Open()
$oComPort.Write("AT")
$oComPort.Write($sQueryString + "`r")
Start-Sleep -m 50
$tVar = $oComPort.ReadExisting()
$tVar = ($tVar -replace "OK","").trim()
$oComPort.Close()

If (!($sRegExp -eq "")) {$tVar -Match $sRegExp|Out-Null; $tVar = $Matches[0]}
return $tVar
}

#AT Commands to pull information from Modems
#"MEID", "+CGSN"			#i.e. "990000780252708"
#"Modem Model", "+CGMM"		#i.e. "MC7750"
#"Phone Number", "+CNUM"	#i.e. "+CNUM: "Line 1","+15514972305",145"
#"SIM", "+ICCID"			#i.e. "ICCID: 89148000000148583496"
#"Firmware Date", "+GMR		#i.e. "33, SWI9600M_03.05.10.09ap r5700 carmd-en-10527 2013/03/12 10:37:48"
#*Commands pulled using AT+CLAC command...

#Grab COMPort number and max ComPort speed
$sComPortNumber = Get-WmiObject Win32_PotsModem | `
	Where-Object {$_.DeviceID -like "USB\VID*" -and $_.Status -like "OK"} | `
	foreach {$_.AttachedTo}
$sModemInfPath = Get-WmiObject Win32_PotsModem | `
	Where-Object {$_.DeviceID -like "USB\VID*" -and $_.Status -like "OK"} | `
	foreach {$_.ModemInfPath}
$sModemDriverVer = Get-WmiObject Win32_PnPSignedDriver | `
	Where-Object {$_.InfName -like $sModemInfPath} | `
	foreach {$_.DriverVersion}
$sComPortSpeed = Get-WMIObject Win32_PotsModem | `
	Where-Object {$_.DeviceID -like "USB\VID*" -and $_.Status -like "OK"} | `
	foreach {$_.MaxBaudRateToSerialPort}

#Populate Variables using fQueryModem Function Call
$sMEID = fQueryModem "+CGSN" "\d{15}"
$sModemModel = fQueryModem "+CGMM" "" #Match Everything
$sPhoneNumber = fQueryModem "+CNUM" "\d{11}"
$sSIM = fQueryModem "+ICCID" "\d{20}"
#$sFirmwareDate = fQueryModem "+GMR" "\d{4}/\d{2}/\d{2}"
$sFirmwareDate = fQueryModem "+GMR" ""

#Populate TXT file with captured variables
$sDate = Get-Date -Format "MM/dd/yyyy"
$sOutString = "Date: $sDate
Username: $env:username
MEID: $sMEID
Modem Model: $sModemModel
Phone Number: $sPhoneNumber
SIM Number: $sSIM
Firmware Date: $sFirmwareDate
Modem Driver: $sModemDriverVer"
$sOutString | Out-File -FilePath "$sCurrentDirectory\ModemInformation.TXT" -Force
