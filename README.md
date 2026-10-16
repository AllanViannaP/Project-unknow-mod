# Project Unknown — More Players

Experimental mod for hosting lobbies with up to 8 players and allowing multiple players to choose the same character.

## Repository contents

- mod/ProjectUnknown-Windows_P.pak: v2 mod package.
- instalador/: Windows installer and uninstaller.

## Installation

Follow these steps on **every computer** that will join the game:

1. Close Project Unknown.
2. Download the repository with **Code → Download ZIP** and extract the entire ZIP to a folder. Do not move files out of mod/ or instalador/ separately.
3. Open the instalador folder and run **Instalar.bat**.
4. Approve the Windows administrator prompt. The installer looks for your Steam library and copies the PAK into the game folder.
5. Wait for the installation-complete message, then restart the game.

If the installer cannot find the game in your Steam library, open PowerShell as an administrator in the extracted repository folder and run:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\instalador\Instalar.ps1" -GameRoot "C:\Program Files (x86)\Steam\steamapps\common\Beast Management"
~~~

Replace the -GameRoot path with the Beast Management folder on your computer.

## Playing together

- Every player, including the host, must install the same v2 PAK for duplicate character selection to work.
- The host creates the lobby. This package supports **up to 8 players total, including the host**.
- The installer sets the limit to 8 by default. To use a lower limit, open PowerShell as an administrator in the repository folder and run the command below. Replace 6 with any value from 5 to 8.

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\instalador\Instalar.ps1" -MaxPlayers 6
~~~

## Uninstallation

Close the game and run instalador/Desinstalar.bat on each computer where you want to remove the mod. The uninstaller restores the previous PAK if a backup exists and removes the MaxPlayers setting added by the mod. The original Game.ini backup is kept.

## Notes

This mod is experimental. The v2 package was checked statically, but it still needs to be validated in a real multiplayer match with all participants. A game update may make it incompatible.
