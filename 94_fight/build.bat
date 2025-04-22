@echo off
setlocal

REM Get the directory of this batch file
set workspaceFolder=%~dp0

REM Create the output directory
if not exist "%workspaceFolder%\output" (
    mkdir "%workspaceFolder%\output"
)

assembler\Assembler.exe /p /m /g /o d- /o s- /o r+ /o l+ /o l. /o ow+ /o op- /o os+ /o oz+ /o omq- /o oaq+ /o osq+  patch.asm,output\nhl94_patched.bin > output\Build.log