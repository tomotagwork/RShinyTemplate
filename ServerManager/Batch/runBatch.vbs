dim batFile,var1,var2

if WScript.Arguments.Count = 0 then
	'WScript.Echo("too few args")
	WScript.Quit(-1)
end if

if WScript.Arguments.Count = 1 then
	batFile=WScript.Arguments(0)
end if

if WScript.Arguments.Count = 2 then
	batFile=WScript.Arguments(0)
	var1=WScript.Arguments(1)
end if

if WScript.Arguments.Count = 3 then
	batFile=WScript.Arguments(0)
	var1=WScript.Arguments(1)
	var2=WScript.Arguments(2)
end if

command="cmd /c " & batFile & " " & var1 & " " & var2

Set ws = CreateObject("WScript.Shell")
ws.run command , vbhide
