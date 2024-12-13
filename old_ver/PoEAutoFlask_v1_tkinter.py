from random import randint
import threading
from time import sleep
import pyautogui
import keyboard
from pynput import mouse
import tkinter as tk
from win32gui import GetWindowText, GetForegroundWindow
import time

import win32con
from PIL import Image, ImageTk
import ctypes
import queue

# Create a queue for thread-safe communication
event_queue = queue.Queue()


pyautogui.PAUSE = 0
pyautogui.FAILSAFE = False
pyautogui.MINIMUM_SLEEP = 0
pyautogui.MINIMUM_DURATION = 0

botting = False #bot is on
SkillSpam = False #bot is using skills
rightClicked = False #Right click pressed
leftClicked = False
middleClicked = False
windowName = "Path of Exile 2"

#Extra functionality for left click holding
walkCast=False
press_time = 0
hold_threshold = 3  # seconds

#Cast after roll
rollCast=False

#Key list for auto rotation
keyList=['shift+e','shift+r','shift+2','shift+q']

#Key list for skills
commandMinions_s="1"
roll_s="space"

#Toggle buttons
walkCast_btn='ñ'
rollCast_btn='0'

##### Overlay

# Initialize the overlay window as hidden
root = tk.Tk()
root.withdraw()  # Start with the window hidden
root.overrideredirect(True)
root.geometry("+10+10")  # Position the window
root.lift()
root.wm_attributes("-topmost", True)
root.wm_attributes("-disabled", True)
root.wm_attributes("-transparentcolor", "white")
root.attributes("-alpha", 0.0)  # Set transparency

# Make the window click-through
hwnd = ctypes.windll.user32.GetForegroundWindow()
styles = ctypes.windll.user32.GetWindowLongW(hwnd, win32con.GWL_EXSTYLE)
styles = styles | win32con.WS_EX_LAYERED | win32con.WS_EX_TRANSPARENT
ctypes.windll.user32.SetWindowLongW(hwnd, win32con.GWL_EXSTYLE, styles)
ctypes.windll.user32.SetLayeredWindowAttributes(hwnd, 0, 255, win32con.LWA_ALPHA)

# Load the icons
icon_path = '.\img\icon.png'
castWalk_path = '.\img\castWalk.png'
castRoll_path = '.\img\castRoll.png'

icon = Image.open(icon_path).convert("RGBA")
icon = icon.resize((50, 50))  # Resize the icon if needed
icon = ImageTk.PhotoImage(icon)

castWalk_icon = Image.open(castWalk_path).convert("RGBA")
castWalk_icon = castWalk_icon.resize((50, 50))  # Resize the icon if needed
castWalk_icon = ImageTk.PhotoImage(castWalk_icon)

castRoll_icon = Image.open(castRoll_path).convert("RGBA")
castRoll_icon = castRoll_icon.resize((50, 50))  # Resize the icon if needed
castRoll_icon = ImageTk.PhotoImage(castRoll_icon)

#####

# Function to update the overlay
def update_ui():
    try:
        # Process all pending messages in the queue
        while not event_queue.empty():
            action = event_queue.get_nowait()
            if action == "update":
                showText()
    except queue.Empty:
        pass
    finally:
        root.update_idletasks()  # Ensure updates are handled here
        root.update()  # Refresh the UI
        # Schedule the next update
        root.after(100, update_ui)

def get_active_window():
    root.update_idletasks()
    root.update()
    return (GetWindowText(GetForegroundWindow()) == windowName)

#Toggle bot on/off
def switchBot(kb_event_info):
    global botting
    botting = not botting
    event_queue.put("update")  # Notify the UI to update

#Hard stop the bot
def stopBot(kb_event_info):
    global botting
    botting = False
    event_queue.put("update")  # Notify the UI to update



# Display the icons to show the bot status
def showText():
    global botting, walkCast, rollCast
    # Clear all existing widgets
    for widget in root.winfo_children():
        widget.destroy()

    # Check if botting is active and the correct window is in focus
    if botting and get_active_window():
        # Create the main bot status icon
        tk.Label(root, image=icon, bg='white').grid(row=0, column=0)
        # Add additional indicators if walkCast or rollCast are enabled
        if walkCast:
            tk.Label(root, image=castWalk_icon, bg='white').grid(row=0, column=1)
        if rollCast:
            tk.Label(root, image=castRoll_icon, bg='white').grid(row=0, column=2)

        root.deiconify()  # Show the window
        root.update_idletasks()  # Refresh the display
    else:
        root.withdraw()  # Hide the window



def toggleSkillOn(kb_event_info):
    #print('skill pressed!')
    global SkillSpam
    if not SkillSpam:
        SkillSpam = True
        time.sleep(0.05)
    
def toggleSkillOff(kb_event_info):
    global SkillSpam
    if SkillSpam:
        SkillSpam = False
        time.sleep(0.05)

#Extra functionality toggle:
#Command minions while walking
def toggleWalkCast(kb_event_info):
    global walkCast
    walkCast = not walkCast
    event_queue.put("update")  # Notify the UI to update

#Roll after cast toggle
def toggleRollCast(kb_event_info):
    global rollCast
    rollCast = not rollCast
    event_queue.put("update")  # Notify the UI to update

#Mouse click actions/bindings
def on_click(x, y, button, pressed):
    global rightClicked,leftClicked,middleClicked,walkCast,press_time,hold_threshold
    if pressed:
        #print(button)
        if walkCast and (button == mouse.Button.left):
            press_time = time.time()  # Record the time when the button is pressed
            leftClicked =True
            threading.Thread(target=check_hold_duration).start()  # Start checking for hold
            #toggleSkillOn(None)
        if (button == mouse.Button.right):
            rightClicked =True
            toggleSkillOn(None)
        if (button == mouse.Button.middle):
            middleClicked =True
            toggleSkillOn(None)
        # if (button == mouse.Button.x1) or (button == mouse.Button.x1):
        #     toggleSkillOn(None)
        return
    else:
        if rightClicked:
            rightClicked = False
        if leftClicked:
            leftClicked = False
            press_time = 0
        if middleClicked:
            middleClicked = False
        toggleSkillOff(None)
        return
        
def check_hold_duration():
    global press_time, leftClicked
    while leftClicked:  # While the button is still pressed
        duration = time.time() - press_time
        if duration >= hold_threshold and leftClicked:
            toggleSkillOn(None)  # Trigger hold action
            return  # Exit the loop once the hold action is triggered
        time.sleep(0.01)  # Check every 10ms to avoid high CPU usage

def main():
    global botting
    if __name__== "__main__" :
        keyboard.on_press_key('º',switchBot)
        keyboard.on_press_key('enter',stopBot)
        listener = mouse.Listener(on_click=on_click)
        listener.start()
        keyboard.on_press_key(walkCast_btn,toggleWalkCast)
        keyboard.on_press_key(rollCast_btn,toggleRollCast)
        # keyboard.on_press_key('w',toggleSkillOn)
        # keyboard.on_release_key('w',toggleSkillOff)

        while True:
            is_game_active = get_active_window()
            if is_game_active:
                if botting:
                    if SkillSpam:
                        commandMinions()  # Perform bot actions
                    time.sleep(0.05)
            else:
                # Hide the overlay if the game is not active
                root.withdraw()
                time.sleep(0.1)

    

##### SKILLS

def commandMinions():
    global rollCast,leftClicked
    sleep(randint(150, 250)/1000)
    keyboard.send(commandMinions_s)
    #pyautogui.press(commandMinions_s)
    # keyboard.press(commandMinions_s)
    # sleep(randint(10, 50)/1000)
    # keyboard.release(commandMinions_s)
    if (not leftClicked) & rollCast:
        sleep(randint(250, 350)/1000)
        keyboard.send(roll_s)

#####

if __name__ == "__main__":
    # Initialize the UI
    root.after(100, update_ui)
    main()