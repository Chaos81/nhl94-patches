echo build_4MB.bat version 0.1
echo Builds a 4MB version of the NHL94 ROM

@echo off
setlocal

REM Get the directory of this batch file
set workspaceFolder=%~dp0

REM Create the output directory
if not exist "%workspaceFolder%\output" (
    mkdir "%workspaceFolder%\output"
)

assembler\Assembler.exe /p /m /g /o d- /o s- /o r+ /o l+ /o l. /o ow+ /o op- /o os+ /o oz+ /o omq- /o oaq+ /o osq+  scripts\94_to_4MB.asm,output\nhl94_4MB.bin > output\Build.log