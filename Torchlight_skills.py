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
windowName = "Torchlight: Infinite  "


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
    if pressed:
        #print(button)
        if (button == mouse.Button.right):
            sleep(randint(150, 250)/1000)
            #toggleSkillOn(None)
            fullRotation_minion()
            return
        #if (button == mouse.Button.x1) or (button == mouse.Button.x1):
        #    sleep(randint(50, 150)/1000)
        #    blink_summon()
        #    toggleSkillOn(None)
        #    return
        else:
            return
    else:
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
                        fullRotation_minion()
                        #toggleSkillOff(None)
            if not botting:
                time.sleep(0.1)
    
    listener.join()
    

def fullRotation_minion():
    #keyboard.send("w")
    #sleep(randint(10, 70)/1000)
    keyboard.send("e")
    sleep(randint(10, 70)/1000)
    keyboard.send("q")
    sleep(randint(10, 70)/1000)
    # keyboard.send("d")
    # sleep(randint(10, 70)/1000)


def blink_summon():
    keyboard.send("r")
    sleep(randint(10, 70)/1000)

main()