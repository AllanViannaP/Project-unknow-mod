Set sh = CreateObject("Shell.Application")
script = WScript.Arguments(0)
args = "-NoProfile -ExecutionPolicy Bypass -NoExit -File " & Chr(34) & script & Chr(34)
sh.ShellExecute "powershell.exe", args, "", "runas", 1
