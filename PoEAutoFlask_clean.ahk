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
;FlaskDurationInit["s"] := 5000
;FlaskDurationInit[2] := 5000 ;6500	
;FlaskDurationInit[3] := 4800		; Rumi's armor(4800)
;FlaskDurationInit[4] := 8000		; divination(5000)/armor(4000x2 so they dont stack after 1st time)
;FlaskDurationInit[5] := 4900		; QS(4800)

;--Spell list
;SpellDurationInit["d"] := 10000		; Convocation(3000/3100)
;SpellDurationInit[8] := 2000		; PhaseRun(4000)/Molten Shell(~8700)/MS+19%(~9500)
SpellDurationInit[9] := 1000		;steelskin/vaalMS
;SpellDurationInit["t"] := 1000		;vaalHaste


;--Buff flask list(queued one after another)
;FlaskDurationBuffInit["s"] := 2000
FlaskDurationBuffInit[2] := 6000 ;6500		; experimenter's granite(6400)/silver(6000)
FlaskDurationBuffInit[3] := 6000		; divination(5000)/armor(4000)/basalt(5400)/experimenter's(6200)
FlaskDurationBuffInit[4] := 6000		; Rumi's armor(4800)/taste of hate(4800)
;FlaskDurationBuffInit[5] := 4900

;--QuickSilver flask list
;FlaskDurationQSInit[4] := 6000	; QS1(4800)
FlaskDurationQSInit[5] := 6000	; QS2(6100)/Rotgut(6000)


queueLife := 1				; set to 0 to spam the flasks instead
queueBuff := 0				; set to 0 to spam the flasks instead
timeBeforeHeal := 0			; time before using a life flask when pressing the attack button, set unless you got 0 ES(default=0)
attacktimeout := 2000		; time between attacks(default=500)
attacktimeout_long := 600000	; ingame toggle for the attack timeout
attacktimeout_life := 2000	; time to keep using life flasks after attacking
qstimeout := 200			; time to keep using qs after clicking(default=200)
osb := "t"					; oh-Shit buttons to spam 2 defensive skill at once when pressing "w", set to 0 if not used(default="r")
osb2 := "1"					; I used this for vaal skills, to change the default("w") hotkey go down to the hotkey section.
; spells to trigger when scrolling the mouse wheel or shift set to 0 to disable(default="f")
WUButtonTrigger1 := 0
WUButtonTrigger2 := 0	;"{MButton}"
WDButtonTrigger1 := 0
WDButtonTrigger2 := 0
ShiftTrigger1 := 0
ShiftTrigger2 := 0
gemswap_hotkey := false	;enable/disable gem swapping except the portal swap
default_chatkey := true
RightClickSkill := true ;use skill on right click
2RightClickSkill := true ;use 2 skills on right click


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
attacktimeout_life_backup := -1
useAllFlasks := false ; use all flasks when pressing d even if the bot is off(for bossing)

walkspam := true ;spam while walking(like qs)

chatPause := false
unfocusedPause := false

;----------------------------------------------------------------------
; Main program loop - basics are that we use flasks whenever flask
; usage is enabled via hotkey (default is F12), and we've attacked
; within the last 0.5 second (or are channeling/continuous attacking.
;----------------------------------------------------------------------

Loop {
	
	if (not WinActive("Path of Exile")) {
		if (UseFlasks) {
			unfocusedPause := true
			UseFlasks := false
			if (longTimeout) {
				attacktimeout := attacktimeout_backup
				longTimeout := false
			}
			ToolTip, AutoFlasks Off, 0, 0
			SetTimer, RemoveToolTip, -5000
		}
	} else {
		if (unfocusedPause) {
			unfocusedPause := false
			UseFlasks := true
			;ToolTip, AutoFlasks, 0, 0
			;SetTimer, RemoveToolTip, Off
			if (longTimeout) {
				ToolTip, AutoFlasks L, 0, 0
				SetTimer, RemoveToolTip, Off
			} else {
				ToolTip, AutoFlasks, 0, 0
				SetTimer, RemoveToolTip, Off
			}
		}
	}

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
			Gosub, CycleBuffFlasksWhenReady
			;if (not walkspam){ ; if spamming while walking do it on left click instead
				Gosub, CycleAllSpellsWhenReady
			;}
		} else {
			; We haven't attacked recently, but are we channeling/continuous?
			if (HoldRightClick) {
				Gosub, CycleBuffFlasksWhenReady
				;if (not walkspam){ ; if spamming while walking do it on left click instead
					Gosub, CycleAllSpellsWhenReady
				;}
			}
		}
		if ((A_TickCount - LastLeftClick) < qstimeout) {
			Gosub, CycleQSFlasksWhenReady
			if (walkspam){ ; if spamming while walking do it on left click instead
				Gosub, CycleAllSpellsWhenReady
			}
		} else {
			if (HoldLeftClick) {
				Gosub, CycleQSFlasksWhenReady
				if (walkspam){
					Gosub, CycleAllSpellsWhenReady
				}
			}
		}
	}
	sleep, 75
}


~Enter::
;~Ctrl::
	gosub, StopBot_noinput
	return

XButton2::
CapsLock::
+z::
	BlockInput MouseMoveOff	;disable block mouse input in case it gets stuck somehow(failsafe, not necessary at all)
	BlockInput Off
	tabbing := false

	UseFlasks := not UseFlasks
	if UseFlasks {
		useAllFlasks := false ;stop using all at the same time
		attacktimeout_life_backup := -1
		attacktimeout_backup := -1
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
			attacktimeout_life := attacktimeout_life_backup
			longTimeout := false
		}
		ToolTip, AutoFlasks Off, 0, 0
		SetTimer, RemoveToolTip, -5000
	}
	return

;;XButton2::
~<::
	if (attacktimeout_backup == -1) {
		attacktimeout_backup := attacktimeout
	}
	if (attacktimeout_life_backup == -1) {
		attacktimeout_life_backup := attacktimeout_life
	}
	if UseFlasks {
		if (longTimeout) {
			attacktimeout := attacktimeout_long
			attacktimeout_life := attacktimeout_long
			ToolTip, AutoFlasks L, 0, 0
		} else {
			attacktimeout := attacktimeout_backup
			attacktimeout_life := attacktimeout_life_backup
			attacktimeout_life_backup := -1
			attacktimeout_backup := -1
			ToolTip, AutoFlasks, 0, 0
		}
		longTimeout := not longTimeout
	}
	return

~+d::
	if UseFlasks {
		useAllFlasks := true
		gosub, StopBot
		ToolTip, Bossing, 0, 0
		SetTimer, RemoveToolTip, Off
	}
	return

; A little tweak for my preference
RemoveToolTip:
	ToolTip
	return

^F12::
	BlockInput MouseMoveOff	;disable block mouse input in case it gets stuck somehow(failsafe, not necessary at all)
	BlockInput Off
	ExitApp

 ;~LAlt::
 ;~LWin::
 ;~ $~LShift::
 ;~ $~LControl::
  	;~ ;StopBot_noinput()
  	;~ gosub, StopBot_noinput
	;~ return


~F5::
	;StopBot()
	gosub, StopBot
	return

~F12::
	;MouseMove, 0, 1079, 0
	MouseMove, 5, 5, 0
	Send {Ctrl up}	;failsafe for when using the script mid combat when we are holding buttons and such(we could grab the equipment otherwise)
	Send {Alt up}
	;StopBot()
	gosub, StopBot
	return

;StopBot(){
StopBot:
		BlockInput MouseMoveOff	;disable block mouse input in case it gets stuck somehow(failsafe, not necessary at all)
		BlockInput Off
		Send {LButton up}	;failsafe for when using the script mid combat when we are holding buttons and such(we could grab the equipment otherwise)
		Send {RButton up}
		;Send {Ctrl up}	;failsafe for when using the script mid combat when we are holding buttons and such(we could grab the equipment otherwise)
		;Send {Alt up}
		global UseFlasks
		global longTimeout
		global attacktimeout
		global attacktimeout_backup
		global attacktimeout_life
		global attacktimeout_life_backup
		if (UseFlasks) {
			UseFlasks := false
			ToolTip, OFF, 0, 0
			;SetTimer, RemoveToolTip, -5000
			if (longTimeout) {
				attacktimeout := attacktimeout_backup
				attacktimeout_life := attacktimeout_life_backup
				longTimeout := false
			}
		}
	;}
	return

;StopBot_noinput(){
StopBot_noinput:
		global UseFlasks
		global longTimeout
		global attacktimeout
		global attacktimeout_backup
		global attacktimeout_life
		global attacktimeout_life_backup
		if (UseFlasks) {
			UseFlasks := false
			ToolTip, OFF, 0, 0
			;SetTimer, RemoveToolTip, -5000
			if (longTimeout) {
				attacktimeout := attacktimeout_backup
				attacktimeout_life := attacktimeout_life_backup
				longTimeout := false
			}
		}
	;}
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
~XButton1::
;;~XButton2::
~w::
~e::
~RButton::
	if ((UseFlasks or useAllFlasks) && RightClickSkill) {
		Random, VariableDelay, -50, 50
		Sleep, %VariableDelay%
		Send t
		if (2RightClickSkill) {
			Random, VariableDelay, -50, 50
			Sleep, %VariableDelay%
			Send 9
		}
	}
	; pass-thru and capture when the last attack (Right click) was done
	; we also track if the mouse button is being held down for continuous attack(s) and/or channelling skills
	HoldRightClick := true
	LastRightClick := A_TickCount
	return

~XButton1 up::
~XButton2 up::
~w up::
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

;~ XButton2:: ;mouse 5
;~ XButton1:: ;mouse4
	;~ if (UseFlasks or useAllFlasks) {
		;~ Send t
	;~ }

 ;~ ~Shift::
;~ ; trigger 2 spells with middle mouse button
	;~ if (UseFlasks && (ShiftTrigger1 <> 0)) {
  		;~ Send %ShiftTrigger1%
  		;~ if (ShiftTrigger2 <> 0){
  			;~ Send %ShiftTrigger2%
  		;~ }
  	;~ }
  	;~ return

 ;~ ~WheelUp::
	;~ ; trigger 2 spells with middle mouse button
	;~ if (UseFlasks && (WUButtonTrigger1 <> 0)) {
 		;~ Send %WUButtonTrigger1%
 		;~ if (WUButtonTrigger2 <> 0){
 			;~ Send %WUButtonTrigger2%
 		;~ }
 	;~ }
	;~ if (UseFlasks) {
		;~ Send w
	;~ }
 	;~ return

 ;~ ~WheelDown::
 	;~ ; trigger 2 spells with middle mouse button
 	;~ if (UseFlasks && (WDButtonTrigger1 <> 0)) {
 		;~ Send %WDButtonTrigger1%
 		;~ if (WDButtonTrigger2 <> 0){
 			;~ Send %WDButtonTrigger2%
 		;~ }
 	;~ }
	;~ if (UseFlasks) {
		;~ MouseClick, Left
		;~ Random, VariableDelay, -99, 99
		;~ Sleep, %VariableDelay%
		;~ MouseClick, Right
		;~ Random, VariableDelay, -99, 99
		;~ Sleep, %VariableDelay%
		;~ MouseClick, Left
		;~ Random, VariableDelay, -99, 99
		;~ Sleep, %VariableDelay%
	;~ }
 	;~ return

;~ ~WheelDown::
	;~ if (UseFlasks) {
		;~ SetTimer, HoldClick, -1 ;-1 to run once
	;~ }
	;~ return

HoldClick:
    kDown := A_TickCount
    While ((A_TickCount - kDown) < 100)
    {
        SendInput, {LButton down}
        Random, VariableDelay, -50, 50
		Sleep, %VariableDelay%
		MouseClick, Right
		Random, VariableDelay, -50, 50
		Sleep, %VariableDelay%
		SendInput, {LButton up}
        Random, VariableDelay, -50, 50
		Sleep, %VariableDelay%
    }
	SendInput, {LButton up}
Return


+f::
	if True {
		; disconnect hotkey
		Run cports.exe /close * * * * PathOfExile.exe
	}
	return

;----------------------------------------------------------------------
; The following 5 hotkeys allow for manual use of flasks while still
; tracking optimal recast times.
;----------------------------------------------------------------------
/* ~1::
 * 	; pass-thru and start timer for flask 1
 * 	FlaskLastUsed[1] := A_TickCount
 * 	Random, VariableDelay, -99, 99
 * 	FlaskDuration[1] := FlaskDurationInit[1] + VariableDelay ; randomize duration to simulate human
 * 	return
 */

/* ~2::
 * 	; pass-thru and start timer for flask 2
 * 	FlaskLastUsed[2] := A_TickCount
 * 	Random, VariableDelay, -99, 99
 * 	FlaskDuration[2] := FlaskDurationInit[2] + VariableDelay ; randomize duration to simulate human
 * 	return
 */

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
~d::
	if useAllFlasks{
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
		;Random, VariableDelay, -99, 99
		;Sleep, %VariableDelay%
		;Send e
		;Random, VariableDelay, -99, 99
		;Sleep, %VariableDelay%
		;Send r
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

#IfWinActive