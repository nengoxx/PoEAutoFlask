;----------------------------------------------------------------------
; PoE Flasks macro for AutoHotKey
;
; Keys used and monitored:
; alt+f12 - activate automatic flask usage
; right mouse button - primary attack skills
; 1-5 - number keys to manually use a specific flask
; ` (backtick) - use all flasks, now
; "e" and "q" for casting buffs
; Note - the inventory buttons assume a starting location based on screen
; resolution - you'll need to update some locations, see below.
; Alt+c to Ctrl-Click every location in the (I)nventory screen.
; Alt+m - Allow setting stash tab size as normal (12x12) or large (24x24)
; Alt+g - Get the current screen coordinates of the mouse pointer.
; Alt+s - Swap a skill gem with an alternate.
;----------------------------------------------------------------------
#IfWinActive Path of Exile
#SingleInstance force
#NoEnv
#Warn
#Persistent

SpellDurationInit := []
FlaskDurationInit := []
FlaskDurationBuffInit := []
FlaskDurationQSInit := []
LifeFlasks := 0
BuffFlasks := 0
QSFlasks := 0
;----------------------------------------------------------------------
; Set the duration of each flask, in ms, below.  For example, if the
; flask in slot 3 has a duration of "Lasts 4.80 Seconds", then use:
;		FlaskDurationInit[3] := 4800
;
; To disable a particular flask, set it's duration to 0
;
; Note: Delete the last line (["e"]), or set value to 0, if you don't use a buff skill
;----------------------------------------------------------------------
;--Life Flask list (currently spammable flasks and spells on cd)
FlaskDurationInit[1] := 2600	; karui life(2500)
FlaskDurationInit[2] := 1000	; 2ndkarui(2700)/life(4000)/basalt(4500)
;FlaskDurationInit[3] := 4800	; Rumi's armor(4800)
;FlaskDurationInit[4] := 8000	; divination(5000)/armor(4000x2 so they dont stack after 1st time)
;FlaskDurationInit[5] := 4900	; QS(4800)

;--Spell list
SpellDurationInit["e"] := 3200	; Convocation(3000/3100)
SpellDurationInit["q"] := 9700	; Molten Shell(~8700)/MS+19%(~9500)
SpellDurationInit["f"] := 14000	; Offering(15000)

;--Buff flask list(queued one after another)
FlaskDurationBuffInit[3] := 6500	; divination(5000)/armor(4000)/basalt(5400)/experimenter's(6200)
FlaskDurationBuffInit[4] := 5600	; Rumi's armor(4800)

;--QuickSilver flask list
;FlaskDurationQSInit[4] := 4900	; QS1(4800)
FlaskDurationQSInit[5] := 6200	; QS2(6100)/Rotgut(6000)

queueLife := 1				; set to 0 to spam the flasks instead
queueBuff := 0				; set to 0 to spam the flasks instead
timeBeforeHeal := 0			; time before using a life flask when pressing the attack button, set unless you got 0 ES(default=0)
attacktimeout := 2000		; time between attacks(default=500)
attacktimeout_long := 12000	; ingame toggle for the attack timeout
attacktimeout_life := 2000	; time to keep using life flasks after attacking
qstimeout := 200			; time to keep using qs after clicking(default=200)
osb := "t"					; oh-Shit buttons to spam 2 defensive skill at once when pressing "w", set to 0 if not used(default="r")
osb2 := "2"					; I used this for vaal skills, to change the default("w") hotkey go down to the hotkey section.
; spells to trigger when scrolling the mouse wheel or shift set to 0 to disable(default="f")
WUButtonTrigger1 := 0
WUButtonTrigger2 := 0	;"{MButton}"
WDButtonTrigger1 := 0	
WDButtonTrigger2 := 0	
ShiftTrigger1 := 0
ShiftTrigger2 := 0

; variables to initialize
FlaskDuration := []
SpellDuration := []
FlaskDurationBuff := []
FlaskDurationQS := []

lastLifeFlaskDuration := 0
lastBuffFlaskDuration := 0
lastQSFlaskDuration := 0

FlaskLastUsed := []
SpellLastUsed := []
FlaskLastUsedBuff := []
FlaskLastUsedQS := []

lastLifeFlaskUsed := 0		;life
lastBuffFlaskUsed := 0		;buff
lastQSFlaskUsed := 0		;qs

UseFlasks := false
HoldRightClick := false
HoldLeftClick := false
LastRightClick := 0
LastLeftClick := 0
longTimeout := false	; toggle attacktimeout ingame
attacktimeout_backup := -1

chatPause := false
;----------------------------------------------------------------------
; The following are used for fast ctrl-click from the Inventory screen
; using alt-c.  The coordinates for ix,iy come from MouseGetPos (Alt+g)
; of the top left location in the inventory screen.  The delta is the
; pixel change to the next box, either down or right.
;
; To get the correct values for use below, do the following:
;	1. Load the macro into AutoHotKey
;	2. open Inventory screen (I) and place the mouse cursor in the
;	   middle of the top left inventory box.
;	3. Press Alt+g and note the coordinates displayed by the mouse.
;   4. Replace the coordinates below.
;	5. To get the "delta", do the same for the next inventory box down
;	   and note the difference
;----------------------------------------------------------------------
ix       := 1730
iy       :=  818
delta    :=   70

;----------------------------------------------------------------------
; The following are used for fast ctrl-click from Stash tabs into the
; inventory screen, using alt-m.
; Stash top left and delta for 12x12 and 24x24 stash are defined here.
; As above, you'll use Alt+g to determine the actual values needed.
;
; To get these values, follow the instructions for the Inventory screen
; except use the stash tab boxes, instead.  Note, the first COLUMN is
; for the 12x12 stash and the second COLUMN is for the 24x24 "Quad" stash.
;----------------------------------------------------------------------
StashX    := [ 60,  40]
StashY    := [253, 234]
StashD    := [ 70,  35]
StashSize := [ 12,  24]

;----------------------------------------------------------------------
; The following are used for gem swapping.  Useful
; when you use one skill for clearing and another for bossing.
; Put the coordinates of your primary attack skill in PrimX, PrimY
; Put the coordinates of alternate attack skill in AltX, AltY
; Note that the coordinates should be from the CENTER of the gem slot to work correctly due to the random variable.
; WeaponSwap determines if alt gem is in inventory or alternate weapon.
;----------------------------------------------------------------------
;This one is for swapping the portal gem in, using it adn then swappig it out(double swap)
PrimX := 1483	;gem to swap out
PrimY := 306
AltX  := 1295	;portal gem in inventory
AltY  := 617
pixelOffset := 3		;Offset of pixels to randomize in order to not click twice on the same pixel(would be a huge red flag otherwise)
aux_PrimXa := PrimX-pixelOffset
aux_PrimXb := PrimX+pixelOffset
aux_PrimYa := PrimY-pixelOffset
aux_PrimYb := PrimY+pixelOffset
aux_AltXa := AltX-pixelOffset
aux_AltXb := AltX+pixelOffset
aux_AltYa := AltY-pixelOffset
aux_AltYb := AltY+pixelOffset
WeaponSwap := False

;Regular gem swap
PrimX_2 := 1353
PrimY_2 := 174
AltX_2  := 1560
AltY_2  := 135
pixelOffset_2 := 3		;Offset of pixels to randomize in order to not click twice on the same pixel(would be a huge red flag otherwise)
aux_PrimXa_2 := PrimX_2-pixelOffset_2
aux_PrimXb_2 := PrimX_2+pixelOffset_2
aux_PrimYa_2 := PrimY_2-pixelOffset_2
aux_PrimYb_2 := PrimY_2+pixelOffset_2
aux_AltXa_2 := AltX_2-pixelOffset_2
aux_AltXb_2 := AltX_2+pixelOffset_2
aux_AltYa_2 := AltY_2-pixelOffset_2
aux_AltYb_2 := AltY_2+pixelOffset_2
WeaponSwap_2 := False

;Regular gem swap 3 (bossing vs mapping gem)
PrimX_3 := 1742
PrimY_3 := 370
AltX_3  := 1298
AltY_3  := 717
pixelOffset_3 := 2		;Offset of pixels to randomize in order to not click twice on the same pixel(would be a huge red flag otherwise)
aux_PrimXa_3 := PrimX_3-pixelOffset_3
aux_PrimXb_3 := PrimX_3+pixelOffset_3
aux_PrimYa_3 := PrimY_3-pixelOffset_3
aux_PrimYb_3 := PrimY_3+pixelOffset_3
aux_AltXa_3 := AltX_3-pixelOffset_3
aux_AltXb_3 := AltX_3+pixelOffset_3
aux_AltYa_3 := AltY_3-pixelOffset_3
aux_AltYb_3 := AltY_3+pixelOffset_3
WeaponSwap_3 := False
;----------------------------------------------------------------------
; Main program loop - basics are that we use flasks whenever flask
; usage is enabled via hotkey (default is F12), and we've attacked
; within the last 0.5 second (or are channeling/continuous attacking.
;----------------------------------------------------------------------
Loop {
	if (UseFlasks) {
		; have we attacked in the last 0.5 seconds?
		if ((A_TickCount - LastRightClick) < attacktimeout_life) {
			if (timeBeforeHeal <> 0) {
				SetTimer, CycleAllFlasksWhenReady, -%timeBeforeHeal%
			} else {
				Gosub, CycleAllFlasksWhenReady
			}
			;Gosub, CycleAllSpellsWhenReady
		} else {
			; We haven't attacked recently, but are we channeling/continuous?
			if (HoldRightClick) {
				Gosub, CycleAllFlasksWhenReady
				;Gosub, CycleAllSpellsWhenReady
			}
		}
		if ((A_TickCount - LastRightClick) < attacktimeout) {
			Gosub, CycleAllSpellsWhenReady
			Gosub, CycleBuffFlasksWhenReady
		} else {
			; We haven't attacked recently, but are we channeling/continuous?
			if (HoldRightClick) {
				Gosub, CycleAllSpellsWhenReady
				Gosub, CycleBuffFlasksWhenReady
			}
		}
		if ((A_TickCount - LastLeftClick) < qstimeout) {
			Gosub, CycleQSFlasksWhenReady
		} else {
			if (HoldLeftClick) {
				Gosub, CycleQSFlasksWhenReady
			}
		}
	}
}

; 'Enter' in virtualkeyboard code/scancode for using apps like poe trades companion and such(doesn't actually work yet)
;note that this won't be consistent when manually using the chat without the enter key(like clicking outside of it)
;~VK0x0D::
;~^SC1C::
;~SC01C::
;~$^VK0xD::
;~VK0xD::
~!Enter::
~+Enter::
~Enter::
	; do nothing if its disabled/paused 
	if (UseFlasks | chatPause) {
		chatPause := not chatPause
		UseFlasks := not UseFlasks
		if UseFlasks {
			; initialize start of auto-flask use
			ToolTip, AutoFlasks, 0, 0
			SetTimer, RemoveToolTip, Off

			; reset usage timers for all flasks
			LifeFlasks := 0
			BuffFlasks := 0
			QSFlasks := 0
			for i in FlaskDurationInit {
				FlaskLastUsed[i] := 0
				FlaskDuration[i] := FlaskDurationInit[i]
				LifeFlasks += 1
			}
			for i in SpellDurationInit {
				SpellLastUsed[i] := 0
				SpellDuration[i] := SpellDurationInit[i]
			}
			for i in FlaskDurationBuffInit {
				FlaskLastUsedBuff[i] := 0
				FlaskDurationBuff[i] := FlaskDurationBuffInit[i]
				BuffFlasks += 1
			}
			for i in FlaskDurationQSInit {
				FlaskLastUsedQS[i] := 0
				FlaskDurationQS[i] := FlaskDurationQSInit[i]
				QSFlasks += 1
			}
		} else {
			if (longTimeout) {
				attacktimeout := attacktimeout_backup
				longTimeout := false
			}
			ToolTip, AutoFlasks Off, 0, 0
			SetTimer, RemoveToolTip, -5000
		}
	}
	return

z::
	BlockInput MouseMoveOff	;disable block mouse input in case it gets stuck somehow(failsafe, not necessary at all)
	UseFlasks := not UseFlasks
	if UseFlasks {
		; initialize start of auto-flask use
		ToolTip, AutoFlasks, 0, 0
		SetTimer, RemoveToolTip, Off

		; reset usage timers for all flasks
		LifeFlasks := 0
		BuffFlasks := 0
		QSFlasks := 0
		for i in FlaskDurationInit {
			FlaskLastUsed[i] := 0
			FlaskDuration[i] := FlaskDurationInit[i]
			LifeFlasks += 1
		}
		for i in SpellDurationInit {
			SpellLastUsed[i] := 0
			SpellDuration[i] := SpellDurationInit[i]
		}
		for i in FlaskDurationBuffInit {
			FlaskLastUsedBuff[i] := 0
			FlaskDurationBuff[i] := FlaskDurationBuffInit[i]
			BuffFlasks += 1
		}
		for i in FlaskDurationQSInit {
			FlaskLastUsedQS[i] := 0
			FlaskDurationQS[i] := FlaskDurationQSInit[i]
			QSFlasks += 1
		}
	} else {
		if (longTimeout) {
			attacktimeout := attacktimeout_backup
			longTimeout := false
		}
		ToolTip, AutoFlasks Off, 0, 0
		SetTimer, RemoveToolTip, -5000
	}
	return

; A little tweak for my preference
RemoveToolTip:
	ToolTip
	return

;----------------------------------------------------------------------
; To use a different moust button (default is right click), change the
; "RButton" to:
;		RButton - to use the {default} right mouse button
;		MButton - to use the {default} middle mouse button (wheel)
;		LButton - to use the {default} Left mouse button
;
; Make the change in both places, below (the first is click,
; 2nd is release of button}
;----------------------------------------------------------------------
~RButton::
	; pass-thru and capture when the last attack (Right click) was done
	; we also track if the mouse button is being held down for continuous attack(s) and/or channelling skills
	HoldRightClick := true
	LastRightClick := A_TickCount
	return

~RButton up::
	; pass-thru and release the right mouse button
	HoldRightClick := false
	return

~LButton::
	; pass-thru and capture when the last attack (Right click) was done
	; we also track if the mouse button is being held down for continuous attack(s) and/or channelling skills
	HoldLeftClick := true
	LastLeftClick := A_TickCount
	return

~LButton up::
	; pass-thru and release the right mouse button
	HoldLeftClick := false
	return
	
~Shift::
	; trigger 2 spells with middle mouse button
	if (UseFlasks && (ShiftTrigger1 <> 0)) {
		Send %ShiftTrigger1%
		if (ShiftTrigger2 <> 0){
			Send %ShiftTrigger2%
		}
	}
	return
	
~WheelUp::
	; trigger 2 spells with middle mouse button
	if (UseFlasks && (WUButtonTrigger1 <> 0)) {
		Send %WUButtonTrigger1%
		if (WUButtonTrigger2 <> 0){
			Send %WUButtonTrigger2%
		}
	}
	return
	
~WheelDown::
	; trigger 2 spells with middle mouse button
	if (UseFlasks && (WDButtonTrigger1 <> 0)) {
		Send %WDButtonTrigger1%
		if (WDButtonTrigger2 <> 0){
			Send %WDButtonTrigger2%
		}
	}
	return

;~ ; Dynamically set the hotkey to de-assign the 1st button triggered when pressing the defensives
;~ Hotkey, %osb%, Attack_timeout_toggle
	;~ return
	
;~ Attack_timeout_toggle:
	;~ if (attacktimeout_backup == -1) {
		;~ attacktimeout_backup := attacktimeout
	;~ }
	;~ if UseFlasks {
		;~ longTimeout := not longTimeout
		;~ if (longTimeout) {
			;~ attacktimeout := attacktimeout_long
			;~ ToolTip, AutoFlasks/%attacktimeout%, 0, 0
		;~ } else {
			;~ attacktimeout := attacktimeout_backup
			;~ ToolTip, AutoFlasks/%attacktimeout%, 0, 0
		;~ }
	;~ }
	;~ return

~<::
	if (attacktimeout_backup == -1) {
		attacktimeout_backup := attacktimeout
	}
	if UseFlasks {
		longTimeout := not longTimeout
		if (longTimeout) {
			attacktimeout := attacktimeout_long
			ToolTip, AutoFlasks/%attacktimeout%, 0, 0
		} else {
			attacktimeout := attacktimeout_backup
			ToolTip, AutoFlasks/%attacktimeout%, 0, 0
		}
	}
	return
	
~W::
	if(UseFlasks && osb <> 0) {
		send %osb%
		if(osb2 <> 0){
			send %osb2%
		}
	}
	return
	
+f::
	if UseFlasks {
		; disconnect hotkey
		Run cports.exe /close * * * * PathOfExile_x64.exe
	}
	return

;----------------------------------------------------------------------
; The following 5 hotkeys allow for manual use of flasks while still
; tracking optimal recast times.
;----------------------------------------------------------------------
~1::
	; pass-thru and start timer for flask 1
	FlaskLastUsed[1] := A_TickCount
	Random, VariableDelay, -99, 99
	FlaskDuration[1] := FlaskDurationInit[1] + VariableDelay ; randomize duration to simulate human
	return

~2::
	; pass-thru and start timer for flask 2
	FlaskLastUsed[2] := A_TickCount
	Random, VariableDelay, -99, 99
	FlaskDuration[2] := FlaskDurationInit[2] + VariableDelay ; randomize duration to simulate human
	return

;~ ~3::
	;~ ; pass-thru and start timer for flask 3
	;~ FlaskLastUsed[3] := A_TickCount
	;~ Random, VariableDelay, -99, 99
	;~ FlaskDuration[3] := FlaskDurationInit[3] + VariableDelay ; randomize duration to simulate human
	;~ return

;~ ~4::
	;~ ; pass-thru and start timer for flask 4
	;~ FlaskLastUsed[4] := A_TickCount
	;~ Random, VariableDelay, -99, 99
	;~ FlaskDuration[4] := FlaskDurationInit[4] + VariableDelay ; randomize duration to simulate human
	;~ return

;~ ~5::
	;~ ; pass-thru and start timer for flask 5
	;~ FlaskLastUsed[5] := A_TickCount
	;~ Random, VariableDelay, -99, 99
	;~ FlaskDuration[5] := FlaskDurationInit[5] + VariableDelay ; randomize duration to simulate human
	;~ return

;~ ~q::
	;~ ; pass-thru and start timer for flask 5
	;~ SpellLastUsed["q"] := A_TickCount
	;~ Random, VariableDelay, -99, 99
	;~ SpellDuration[5] := SpellDurationInit[5] + VariableDelay ; randomize duration to simulate human
	;~ return

;~ ~t::
	;~ ; pass-thru and start timer for flask 5
	;~ SpellLastUsed["e"] := A_TickCount
	;~ Random, VariableDelay, -99, 99
	;~ SpellDuration[5] := SpellDurationInit[5] + VariableDelay ; randomize duration to simulate human
	;~ return

;----------------------------------------------------------------------
; Use all flasks, now.  A variable delay is included between flasks
; NOTE: this will use all flasks, even those with a FlaskDurationInit of 0
;----------------------------------------------------------------------
`::
	if UseFlasks {
		Send 1
		Random, VariableDelay, -99, 99
		Sleep, %VariableDelay%
		Send 2
		Random, VariableDelay, -99, 99
		Sleep, %VariableDelay%
		Send 3
		Random, VariableDelay, -99, 99
		Sleep, %VariableDelay%
		Send 4
		Random, VariableDelay, -99, 99
		Sleep, %VariableDelay%
		Send 5
		Random, VariableDelay, -99, 99
		Sleep, %VariableDelay%
		Send e
		Random, VariableDelay, -99, 99
		Sleep, %VariableDelay%
		Send r
	}
	return

CycleAllFlasksWhenReady:
	for flask, duration in FlaskDuration {
		; skip flasks with 0 duration and skip flasks that are still active
		if ((duration > 0) & (duration < A_TickCount - FlaskLastUsed[flask])) {
			if ( ( LifeFlasks < 2 || queueLife == 0 ) || ( flask != lastLifeFlaskUsed && A_TickCount - lastLifeFlaskDuration > FlaskLastUsed[lastLifeFlaskUsed] ) ) {
				Send %flask%
				FlaskLastUsed[flask] := A_TickCount
				lastLifeFlaskUsed := flask
				Random, VariableDelay, -99, 99
				FlaskDuration[flask] := FlaskDurationInit[flask] + VariableDelay ; randomize duration to simulate human
				lastLifeFlaskDuration := FlaskDuration[flask]
				sleep, %VariableDelay%
			}
		}
	}
	return
	
CycleAllSpellsWhenReady:
	for spell, duration in SpellDuration {
		; skip flasks with 0 duration and skip flasks that are still active
		if ((duration > 0) & (duration < A_TickCount - SpellLastUsed[spell])) {
			Send %spell%
			SpellLastUsed[spell] := A_TickCount
			Random, VariableDelay, -99, 99
			SpellDuration[spell] := SpellDurationInit[spell] + VariableDelay ; randomize duration to simulate human
			sleep, %VariableDelay%
		}
	}
	return

CycleQSFlasksWhenReady:
	for flask, duration in FlaskDurationQS {
		; skip flasks with 0 duration and skip flasks that are still active
		if ((duration > 0) & (duration < A_TickCount - FlaskLastUsedQS[flask])) {
			;check if we have more than 2 flasks or if the last flask used its not the same and has finished already
			if ((QSFlasks < 2 || flask != lastQSFlaskUsed) && (A_TickCount - lastQSFlaskDuration > FlaskLastUsedQS[lastQSFlaskUsed])) {
				Send %flask%
				FlaskLastUsedQS[flask] := A_TickCount
				lastQSFlaskUsed := flask
				Random, VariableDelay, -99, 99
				FlaskDurationQS[flask] := FlaskDurationQSInit[flask] + VariableDelay ; randomize duration to simulate human
				lastQSFlaskDuration := FlaskDurationQS[flask]
				sleep, %VariableDelay%
			}
		}
	}
	return

CycleBuffFlasksWhenReady:
	for flask, duration in FlaskDurationBuff {
		; skip flasks with 0 duration and skip flasks that are still active
		if ((duration > 0) & (duration < A_TickCount - FlaskLastUsedBuff[flask])) {
			;check if we have more than 2 flasks or if the last flask used its not the same and has finished already
			if ( ( BuffFlasks < 2 || queueBuff == 0 ) || ( flask != lastBuffFlaskUsed && A_TickCount - lastBuffFlaskDuration > FlaskLastUsedBuff[lastBuffFlaskUsed] ) ) {
				Send %flask%
				FlaskLastUsedBuff[flask] := A_TickCount
				lastBuffFlaskUsed := flask
				Random, VariableDelay, -99, 99
				FlaskDurationBuff[flask] := FlaskDurationBuffInit[flask] + VariableDelay ; randomize duration to simulate human
				lastBuffFlaskDuration := FlaskDurationBuff[flask]
				sleep, %VariableDelay%
			}
		}
	}
	return

;----------------------------------------------------------------------
; Alt+c to Ctrl-Click every location in the (I)nventory screen.
;----------------------------------------------------------------------
!c::
	Loop, 12 {
		col := ix + (A_Index - 1) * delta
		Loop, 5 {
			row := iy + (A_Index - 1) * delta
			Send ^{Click, %col%, %row%}
		}
	}
	return

;----------------------------------------------------------------------
; Alt+m - Allow setting stash tab size as normal (12x12) or large (24x24)
;
; vMouseRow := 1 (default) means starting in row 1 of stash tab
; always place mouse pointer in starting box
;
; ItemsToMove := 50 (default) is how many items to move to Inventory
;----------------------------------------------------------------------
!m::
Gui, Add, Radio, vSelStash checked, Norm Stash Tab (12x12)
Gui, Add, Radio,, Quad Stash Tab (24x24)
Gui, Add, Text,, &Clicks:
Gui, Add, Edit, w50
Gui, Add, UpDown, vClicks Range1-50, 50
Gui, Add, Text,, Mouse is in &Row:
Gui, Add, Edit, w50
Gui, Add, UpDown, vStartRow Range1-24, 1
Gui, Add, Button, default, OK
Gui, Show
return

ButtonOK:
GuiClose:
GuiEscape:
	Gui, Submit  ; Save each control's contents to its associated variable.
	MouseGetPos, x, y			; start from current mouse pos
	ClickCt := 0
	Loop {
		Send ^{Click, %x%, %y%}
		if (++ClickCt > StashSize[SelStash] - StartRow) {
			StartRow := 1
			x := x + StashD[SelStash]
			y := StashY[SelStash]
			ClickCt := 0
		} else {
			y := y + StashD[SelStash]
		}
	} until (--Clicks <= 0)
	Gui, Destroy
	return

;----------------------------------------------------------------------
; Alt+g - Get the current screen coordinates of the mouse pointer.
;----------------------------------------------------------------------
!g::
	MouseGetPos, x, y
	ToolTip, %x% %y%
	return

;----------------------------------------------------------------------
; Alt+s - Swap a skill gem with an alternate. Gems must be same color if alt
; weapon slot is used for holding gems.
;----------------------------------------------------------------------
!a::
	o_PrimX_2 := 0
	o_PrimY_2 := 0
	o_AltX_2 := 0
	o_AltY_2 := 0
	Random, o_PrimX_2, aux_PrimXa_2, aux_PrimXb_2
	Random, o_PrimY_2, aux_PrimYa_2, aux_PrimYb_2
	Random, o_AltX_2, aux_AltXa_2, aux_AltXb_2
	Random, o_AltY_2, aux_AltYa_2, aux_AltYb_2
	MouseGetPos, x, y					; Save the current mouse position
	Send \	;close all tabs
	Random, VariableDelay, 50, 100
	Send i
	Random, VariableDelay, 250, 500
	Sleep %VariableDelay%
	BlockInput MouseMove		;block mouse input to not mess with the script
	BlockInput Mouse
	Send {Click Right, %o_PrimX_2%, %o_PrimY_2%}
	Random, VariableDelay, 150, 250
	Sleep %VariableDelay%
	if (WeaponSwap_2) {
		Send {x}
		Random, VariableDelay, 150, 250
		Sleep %VariableDelay%
	}
	Send {Click %o_AltX_2%, %o_AltY_2%}
	Random, VariableDelay, 150, 250
	Sleep %VariableDelay%
	if (WeaponSwap_2) {
		Send {x}
		Random, VariableDelay, 150, 250
		Sleep %VariableDelay%
	}
	Send {Click %o_PrimX_2%, %o_PrimY_2%}
	BlockInput MouseMoveOff		;unblock mouse input
	BlockInput Off
	Random, VariableDelay, 250, 500
	Sleep %VariableDelay%
	Send i
	Random, VariableDelay, 150, 250
	Sleep %VariableDelay%
	MouseMove, x, y
	Return
	
~q::
	o_PrimX_3 := 0
	o_PrimY_3 := 0
	o_AltX_3 := 0
	o_AltY_3 := 0
	Random, o_PrimX_3, aux_PrimXa_3, aux_PrimXb_3
	Random, o_PrimY_3, aux_PrimYa_3, aux_PrimYb_3
	Random, o_AltX_3, aux_AltXa_3, aux_AltXb_3
	Random, o_AltY_3, aux_AltYa_3, aux_AltYb_3
	MouseGetPos, x, y					; Save the current mouse position
	Send \	;close all tabs
	Random, VariableDelay, 50, 100
	BlockInput MouseMove		;block mouse input to not mess with the script
	BlockInput Mouse
	Send {LButton up}	;failsafe for when using the script mid combat when we are holding buttons and such(we could grab the equipment otherwise)
	Send {RButton up}
	Send i
	Random, VariableDelay, 150, 200
	Sleep %VariableDelay%
	Send {Click Right, %o_PrimX_3%, %o_PrimY_3%}
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	if (WeaponSwap_3) {
		Send {x}
		Random, VariableDelay, 100, 200
		Sleep %VariableDelay%
	}
	Send {Click %o_AltX_3%, %o_AltY_3%}
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	if (WeaponSwap_3) {
		Send {x}
		Random, VariableDelay, 100, 200
		Sleep %VariableDelay%
	}
	Send {Click %o_PrimX_3%, %o_PrimY_3%}
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	Send {LButton up}	;failsafe for when using the script mid combat when we are holding buttons and such(we could grab the equipment otherwise)
	Send {RButton up}
	Send i
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	MouseMove, x, y
	BlockInput MouseMoveOff		;unblock mouse input
	BlockInput Off
	Return

;Portal Swap
!s::
	o_PrimX := 0
	o_PrimY := 0
	o_AltX := 0
	o_AltY := 0
	Random, o_PrimX, aux_PrimXa, aux_PrimXb
	Random, o_PrimY, aux_PrimYa, aux_PrimYb
	Random, o_AltX, aux_AltXa, aux_AltXb
	Random, o_AltY, aux_AltYa, aux_AltYb
	MouseGetPos, x, y					; Save the current mouse position
	Send \	;close all tabs
	Random, VariableDelay, 50, 100
	Send i	;open inv
	Random, VariableDelay, 200, 300
	Sleep %VariableDelay%
	BlockInput MouseMove	;block mouse input to not mess with the script coordinates
	BlockInput Mouse
	Send {Click Right, %o_PrimX%, %o_PrimY%}	;click gem
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	if (WeaponSwap) {
		Send {x}
		Random, VariableDelay, 100, 200
		Sleep %VariableDelay%
	}
	Send {Click %o_AltX%, %o_AltY%}		;click portal gem in inventory
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	if (WeaponSwap) {
		Send {x}
		Random, VariableDelay, 100, 200
		Sleep %VariableDelay%
	}
	Send {Click %o_PrimX%, %o_PrimY%}	;slot portal
	
	Random, VariableDelay, 200, 500
	Sleep %VariableDelay%
	Send e	;use portal
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	
	Send {Click Right, %o_PrimX%, %o_PrimY%}	;click portal gem
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	if (WeaponSwap) {
		Send {x}
		Random, VariableDelay, 100, 200
		Sleep %VariableDelay%
	}
	Send {Click %o_AltX%, %o_AltY%}		;click original gem in inventory
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	if (WeaponSwap) {
		Send {x}
		Random, VariableDelay, 100, 200
		Sleep %VariableDelay%
	}
	Send {Click %o_PrimX%, %o_PrimY%}	;slot gem back
	BlockInput MouseMoveOff		;unblock mouse input again
	BlockInput Off
	Random, VariableDelay, 200, 300
	Sleep %VariableDelay%
	
	Send i
	Random, VariableDelay, 100, 200
	Sleep %VariableDelay%
	MouseMove, x, y
	Return
