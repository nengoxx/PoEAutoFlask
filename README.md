# PoEAutoFlask 
Automates flasks & skills for 1 button playstyle.

- Uses button 1(bound to command minion) on right click.
- Hold left click for 2 seconds to spam button 1 and keep your minions with you.
- Auto spacebar(bound to roll) after right click.
- Auto mana flask at around 30% (approx, still testing).

ToDO:
- Auto life flask.
- 1-button burst, rotation, weapon swap?
- Shield charge + roll on long left click hold(5-10 sec)?
- DC keybind/auto dc with cports?



# PoEAutoFlask(old PoE1 version)  
Automates the use of flasks for Path of Exile using an AutoHotKey script.

Credit to the author of the source script: https://github.com/JoelStanford/PoEAutoFlask

I tried some more complex scripts but I liked the simplicity on this one and my main idea is to keep it simple while
adding more usability for life or utility flasks(quicksilver, armor, mana, etc).
Nothing about image recognition or other more complex methods, rather I'm planning on adding simple queueing or more
hotkeys to trigger the flasks, like Quicksilver on left click, pop armor/defensive flasks on attack, and queueing
life flasks one after another instead of popping them all at once.

Any ideas are welcome!

PoEAutoFlask        - Original script  
PoEAutoFlask_QS     - Separate Quicksilver on left click  
PoEAutoFlask_QS_Que - Current version where I added queues for flasks (3>4 & 2>5, my setup for 1life/2buff/2qs flasks) and more(read below). 

Added Features in the current version:

- 3 different queues for the flasks:  
	- Quicksilver flasks(triggered in order)
	- Health flasks(option to queue/spam the flasks)
	- Spells(spam on cd)
	- Buff flasks(option to queue/spam the flasks)
	
- You can set the time before using healing flask after clicking the attack button(timeBeforeHeal)
- You can toggle the time between attacks ingame for builds that don't spam attacks('<' key by default)
- Added another variable for the time between attacks in case of the life flask queue to replace the above toggle
- Added a global defensive button to use up to 2 additional spells, like instant heal potion + some vaal
	(I set it to W by default you must change the hotkey itself by yourself)
- Added some simple pause when pressing the enter key when you wanna use the chat, it just works with the enter key so be careful still
- Added some randomness in the gem swapping, didn't check the 'ctrl+click all the inventory' thing since I dont use it but I don't recomment using it without any randomness
- Added another gem swapping method for the portal gem(swap-in, use, swap-out)
- Now blocks the mouse input while gem swapping to prevent any problem
- Changed the bot toggle to "Z"
- Added auto DC on shift+f (you need to place cports.exe in the same folder and it has to be the same version as the game x86/x64)













Original readme:

NOTE: you MUST install AutoHotKey for this script to function!  
NOTE: this will not work properly for Life, Mana or Hybrid style flasks!  

Keys used and monitored:  
alt+f12 - activate/de-activate the script  
right mouse button - primary attack skills  (directions included to change this to another mouse button)
1-5 - number keys to manually use a specific flask  
\` (backtick) - use all flasks, now  
alt+c - Ctrl-Click every location in the (I)nventory screen
alt+m - Move items from Stash (12x12 or 24x24) to inventory - mouse pointer must be above first stash box to click
alt+g - Get the current screen coordinates of the mouse pointer
alt+s - Swap a skill gem with an alternate gem (in inventory or on alternate weapon group)

Notes on Key usage:  
To change the any of the keys, just change the line that ends with :: to the key of your choice.
For instance, if you prefer to use ctrl+f11 to activate and deactivate the script, change the line that is:  
  !F12::  
to:  
  ^F11::  

If you use a keyboard key, such as "q", instead of the right mouse button as your primary attack skill,
then change all occurrences of "Rbutton" to "q" (ignore the double quotes).  

You will need to change the duration of the each flask to match the flasks that you currently use.  The lines:  
  FlaskDurationInit[1] := 4200  
  FlaskDurationInit[2] := 4700  
  FlaskDurationInit[3] := 4800  
  FlaskDurationInit[4] := 6000  
  FlaskDurationInit[5] := 6200  
Control the duration for flasks 1 through 5.  For example, my flask 1 "Lasts 4.20 Seconds" (you see this by
letting the mouse hover over the flask and reading the info about the flask). The value listed for FlaskDurationInit
is the time, in ms, that the flask buff will last once activated.

Note, you can also put a temporary buff in the "e" or "r" action slots and automatically refresh them.  For instance,
I currently have the following setup to trigger the new Steelskin buff every 4.5 seconds:
  FlaskDurationInit["e"] := 4500

At anytime (after activating the script with Alt+F12 [default]), you can also use the keys 1 - 5 to use a single
flask or the \` (backtick key - left of the number 1 on a US keyboard) to use all flasks. Note that using \` to trigger
all flasks will use even those flasks that have a FlaskDurationInit of 0.  
