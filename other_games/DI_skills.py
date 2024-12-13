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

botting = False
SkillSpam = False
triggerSkill = True
rightClicked = False
windowName = "Diablo Immortal"

keyList=['shift+e','shift+r','shift+2','shift+q']


def switchBot(kb_event_info):
    global botting
    botting = not botting
    showText()
    
def stopBot(kb_event_info):
    global botting
    botting = False
    showText()


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
    SkillSpam = True
    
def toggleSkillOff(kb_event_info):
    global SkillSpam
    SkillSpam = False
    
def on_click(x, y, button, pressed):
    global triggerSkill
    global rightClicked
    if pressed:
        #print(button)
        if (button == mouse.Button.right):
            triggerSkill = False
            rightClicked =True
            toggleSkillOn(None)
            keyboard.press("shift")
        if (button == mouse.Button.x1) or (button == mouse.Button.x1):
            # if (button == mouse.Button.x2):
            #     sleep(randint(50, 150)/1000)
            #     keyboard.send('q')
            #     return
            toggleSkillOn(None)
            return
        else:
            return
    else:
        if rightClicked:
            keyboard.release("shift")
            rightClicked = False
        toggleSkillOff(None)
        return
        

def main():
    global botting
    if __name__== "__main__" :
        keyboard.on_press_key('º',switchBot)
        keyboard.on_press_key('enter',stopBot)
        listener = mouse.Listener(on_click=on_click)
        listener.start()
        keyboard.on_press_key('e',toggleSkillOn)
        keyboard.on_release_key('e',toggleSkillOff)
        keyboard.on_press_key('w',toggleSkillOn)
        keyboard.on_release_key('w',toggleSkillOff)
        while True:
            while (get_active_window()):
                if botting:
                    if SkillSpam:
                        #skillThreading2()
                        #fullRotation()
                        if not rightClicked:
                            fullRotation_mage()
                        # else:
                        #     basicAttack()
            if not botting:
                time.sleep(0.1)
    
    listener.join()
    
    
def skillThreading():
    global keyList
    skillThread = 0
    x = None
    while (skillThread < len(keyList)):
        x = threading.Thread(target=keyThread_send, args=(keyList[skillThread],))
        x.start()
        skillThread += 1
    x.join()
    
def keyThread_send(key):
    sleep(randint(50, 150)/1000)
    keyboard.send(key)
    
def skillThreading2():
    global keyList
    skillThread = 0
    x=None
    while (skillThread <= len(keyList)/2):
        #x = threading.Thread(target=keyThread, args=(keyList[skillThread],keyList[skillThread+1]))
        x = threading.Thread(target=keyThread2_send, args=(skillThread,))
        x.start()
        skillThread += 2
    x.join()

def keyThread2_send(key):
    global keyList
    keyboard.send('shift+space')
    sleep(randint(50, 150)/1000)
    if not SkillSpam:
        return
    keyboard.send(keyList[key])
    sleep(randint(50, 150)/1000)
    if not SkillSpam:
        return
    keyboard.send(keyList[key+1])
    sleep(randint(50, 150)/1000)

def skillPress():
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
    keyboard.release("q")    
    

def skillPress_send():
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
    keyboard.send(keyList[3])                
                    
                    
def skillPress_long():
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
    
    toggleSkillOff(None)
    
def fullRotation():
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
    sleep(randint(10, 70)/1000)
    
    
def fullRotation_mage():
    
    keyboard.send("w")
    sleep(randint(10, 70)/1000)
    keyboard.send("e")
    sleep(randint(10, 70)/1000)
    # keyboard.send("q")
    # sleep(randint(10, 70)/1000)
    # keyboard.send("d")
    # sleep(randint(10, 70)/1000)
    keyboard.send("shift+space")
    sleep(randint(10, 70)/1000)

def basicAttack():
    sleep(randint(20, 150)/1000)
    keyboard.send("shift+space")



main()