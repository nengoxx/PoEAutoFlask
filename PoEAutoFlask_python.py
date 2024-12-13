from random import randint
import threading
from time import sleep
import pyautogui
import keyboard
from pynput import mouse
import tkinter
from win32gui import GetWindowText, GetForegroundWindow
import time


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

#Toggle bot on/off
def switchBot(kb_event_info):
    global botting
    botting = not botting
    showText()

#Hard stop the bot
def stopBot(kb_event_info):
    global botting
    botting = False
    showText()

#Text to show the bot status
def showText():
    global botting
    label = tkinter.Label(text='autoF', font=(None, '12', 'bold'), fg='white', bg='black')
    if ((botting == True) & get_active_window()):
        label.master.overrideredirect(True)
        #label.master.geometry("+5+5")
        label.master.lift()
        label.master.wm_attributes("-topmost", True)
        label.master.wm_attributes("-disabled", True)
        label.master.wm_attributes("-transparentcolor", "black")
        label.pack()
        label.update()
    else:
        label.master.destroy()



def get_active_window():
    return (GetWindowText(GetForegroundWindow()) == windowName)

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

#Roll after cast toggle
def toggleRollCast(kb_event_info):
    global rollCast
    rollCast = not rollCast

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
            while (get_active_window()):
                if botting:
                    if SkillSpam:
                        # fullRotation()
                        #if not rightClicked:
                        #     fullRotation_mage()
                        #    continue
                        #else:
                        commandMinions() #command only on right click
                    time.sleep(0.05)
            if not botting:
                time.sleep(0.1)
    
    
    


""" def skillPress():
    global triggerSkill
    
    if (not triggerSkill):
        sleep(randint(20, 100)/1000)
        keyboard.press("e")
        sleep(randint(10, 50)/1000)
        keyboard.release("e")
        triggerSkill = True
    
    sleep(randint(20, 100)/1000)
    keyboard.press("r")
    sleep(randint(10, 50)/1000)
    keyboard.release("r")
    
    sleep(randint(20, 100)/1000)
    keyboard.press("2")
    sleep(randint(10, 50)/1000)
    keyboard.release("2")
    
    sleep(randint(20, 100)/1000)
    keyboard.press("q")
    sleep(randint(10, 50)/1000)
    keyboard.release("q")  """   
    

""" def skillPress_send():
    global triggerSkill
    
    if (not triggerSkill):
        sleep(randint(20, 100)/1000)
        keyboard.send(keyList[0])
        triggerSkill = True
    
    sleep(randint(20, 150)/1000)
    keyboard.send(keyList[1])
    
    sleep(randint(20, 150)/1000)
    keyboard.send(keyList[2])
    
    sleep(randint(20, 150)/1000)
    keyboard.send(keyList[3])  """               
                    
                    
""" def skillPress_long():
    global triggerSkill
    timeout = time.time() + 2 #2sec
    tries = 0
    #print('pressing skills...')
    
    if (not triggerSkill):
        sleep(randint(100, 200)/1000)
        keyboard.press("e")
        sleep(randint(10, 50)/1000)
        keyboard.release("e")
        triggerSkill = True
    while True:
        sleep(randint(100, 200)/1000)
        keyboard.press("r")
        sleep(randint(10, 50)/1000)
        keyboard.release("r")
    
        sleep(randint(100, 200)/1000)
        keyboard.press("2")
        sleep(randint(10, 50)/1000)
        keyboard.release("2")
    
        sleep(randint(100, 200)/1000)
        keyboard.press("q")
        sleep(randint(10, 50)/1000)
        keyboard.release("q")
        tries += 1
        if tries > 1 or time.time() > timeout:
            break
    
    toggleSkillOff(None) """
    
""" def fullRotation():
    keyboard.send("shift+r")
    sleep(randint(10, 70)/1000)
    if not SkillSpam:
        return
    
    keyboard.send("shift+2")
    sleep(randint(10, 70)/1000)
    if not SkillSpam:
        return
    
    keyboard.send("shift+q")
    sleep(randint(10, 70)/1000)
    if not SkillSpam:
        return
    
    keyboard.send("shift+e")
    sleep(randint(10, 70)/1000)
    if not SkillSpam:
        return
    
    keyboard.send("shift+space")
    sleep(randint(10, 70)/1000) """
    

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



main()