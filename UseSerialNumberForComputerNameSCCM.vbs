'Use Serial Number for Computer Name
strComputer = "."
Set objWMIservice = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
set colitems = objWMIservice.ExecQuery("Select * from Win32_BIOS",,48)
For each objitem in colitems
strComputerName = objitem.serialnumber
Next

SET env = CreateObject("Microsoft.SMS.TSEnvironment") 
env("OSDCOMPUTERNAME") = strComputerName