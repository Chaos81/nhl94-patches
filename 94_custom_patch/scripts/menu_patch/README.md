
# Adding a New Menu Item to NHL '94

## Table of Contents
- [Overview](#overview)
- [Assumptions](#assumptions)
- [Steps](#steps)
  - [1. Define RAM Address for the New Option (`patch.asm`)](#1-define-ram-address-for-the-new-option-patchasm)
  - [2. Add Main Menu Item Text (`menuitems.asm`)](#2-add-main-menu-item-text-menuitemsasm)
  - [3. Add Submenu Item Text and Pointer (`submenuitems.asm`)](#3-add-submenu-item-text-and-pointer-submenuitemsasm)
  - [4. Update Menu Lengths (`menulengths.asm` & `menulengths2.asm`)](#4-update-menu-lengths-menulengthsasm--menulengths2asm)  
  - [5. Implement the New Feature's Logic and Hijack](#5-implement-the-new-features-logic-and-hijack)
  - [6. Assemble and Test](#6-assemble-and-test)

---

## Overview

Okay, let's break down the process of adding a new menu item ("New Feature") with its own sub-options ("Option A", "Option B") to NHL '94, based on the patterns in the provided files.

## Assumptions

- You have a new feature you want to toggle or configure via the main menu.
- You know *where* in the game's logic you need to insert checks for this new feature's setting (the "hijack" point).
- You have written (or will write) the assembly code (`newfeature.asm`) that implements the feature's logic based on the menu setting.

## Steps

### 1. Define RAM Address for the New Option (`patch.asm`)

Just like `FightingRamAddress`, `WeightBugRamAddress`, and `FakeShotRamAddress`, you need to allocate 2 bytes in the `NewMenuRAM` area for your new feature's setting.

Open `patch.asm`.

Find the existing RAM address equates.

Add a new equate *after* the last one, incrementing the offset by 2:

```assembly
; ... existing equates ...
FakeShotRamAddress      equ WeightBugRamAddress+2   ; Address in RAM where the Fake Shot Mode is stored
NewFeatureRamAddress    equ FakeShotRamAddress+2    ; Address in RAM where the New Feature Mode is stored
```

### 2. Add Main Menu Item Text (`menuitems.asm`)

This file defines the text displayed for each item in the main menu.

Open `scripts\menu\menuitems.asm`.

Add a new `MENU` line *before* the `MenuEnd` label:

```assembly
MenuStart:
    ; ... existing MENU lines ...
    MENU 'Fake Shot    '
    MENU 'New Feature  '  ; <-- ADD THIS LINE
MenuEnd:
    dc.l $00400000
```

### 3. Add Submenu Item Text and Pointer (`submenuitems.asm`)

This file defines the text for the options within each submenu and the pointer table mapping main menu items to their submenus.

Open `scripts\menu\submenuitems.asm`.

**a) Add Submenu Text:**

```assembly
; ... existing SUBMENU definitions ...
fakeshot
    SUBMENU 'Off                 '
    SUBMENU 'On                  '

newfeature  ; <-- ADD LABEL FOR NEW SUBMENU
    SUBMENU 'Mode A              '
    SUBMENU 'Mode B              '
```

**b) Add Pointer:**

```assembly
SubMenuItems:
.submenus
    ; Submenu items pointer table
    dc.w playmode-.submenus
    ; ... existing pointers ...
    dc.w fakeshot-.submenus
    dc.w newfeature-.submenus  ; <-- ADD THIS POINTER
playmode
```

### 4. Update Menu Lengths (`menulengths.asm` & `menulengths2.asm`)

These files tell the menu system how many options each main menu item has.

Open `scripts\menu\menulengths.asm` and `scripts\menu\menulengths2.asm`.

Add counts for your new feature:

```assembly
; ... existing counts ...
dc.b 0
dc.b 2    ;Fakeshot # of Options
dc.b 0    ; <-- ADD THIS LINE
dc.b 2    ; <-- ADD THIS LINE (New Feature # of Options)
```

### 5. Implement the New Feature's Logic and Hijack

**a) Create Logic File (`scripts\newfeature\newfeature.asm`):**

```assembly
NewFeatureCheck:
    move.w (NewFeatureRamAddress).w, d0
    btst #0, d0
    beq .modeA
.modeB:
    ; Code to execute if Mode B is selected
    jmp <ReturnAddressB>
.modeA:
    ; Code to execute if Mode A is selected
    jmp <ReturnAddressA>
```

**b) Create Hijack File (`scripts\newfeature\newfeaturehijack.asm`):**

```assembly
; Hijack for New Feature
org $OriginalROMLocation
    jmp NewFeatureCheck
    ; Add NOPs here if the original instruction(s) were longer than 6 bytes
```

**c) Include New Files in `patch.asm`:**

```assembly
; New Code
org NewCodeAddress
    include scripts\fighting\fighting.asm
    include scripts\newfeature\newfeature.asm

; Hijack Code
    include scripts\fighting\fightinghijack.asm
    include scripts\newfeature\newfeaturehijack.asm
```

### 6. Assemble and Test

Assemble `patch.asm` using the provided M68k assembler.

Build the ROM:
- Run the build.bat file to build the rom.

    output/
    ├── Build.log             # Log file containing any errors during compilation.
    ├── nhl94_patched.bin     # Patched ROM file if the build was successful without errors.
    └── nhl94_patched.lst     # Listing file used for debug purposes.

VSCode Task Runner:
- Run the Build NHL 94 Task to build the rom (Same as build.bat).
- Run the Build & Launch Gens Emulator to build and launch the rom in the GENS emulator.