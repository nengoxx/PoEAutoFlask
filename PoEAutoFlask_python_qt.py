from random import randint
import threading
from time import sleep
import pyautogui
import keyboard
from pynput import mouse
from win32gui import GetWindowText, GetForegroundWindow
import time
import sys
import queue

from PySide6.QtWidgets import QApplication, QLabel, QWidget, QVBoxLayout
from PySide6.QtGui import QPixmap, QGuiApplication
from PySide6.QtCore import Qt, QTimer

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

# Load the icons
icon_path = './img/icon.png'
castWalk_path = './img/castWalk.png'
castRoll_path = './img/castRoll.png'

from PySide6.QtWidgets import QApplication, QLabel, QWidget, QVBoxLayout
from PySide6.QtGui import QPixmap, QGuiApplication
from PySide6.QtCore import Qt, QTimer
import ctypes
import sys
import time
from win32gui import GetWindowText, GetForegroundWindow
import queue

# Create a queue for thread-safe communication
event_queue = queue.Queue()

# Constants
WINDOW_NAME = "Path of Exile 2"
ICON_PATH = './img/icon.png'
CAST_WALK_PATH = './img/castWalk.png'
CAST_ROLL_PATH = './img/castRoll.png'

# Bot states
botting = False
walkCast = False
rollCast = False

class Overlay(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowFlags(
            Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.BypassWindowManagerHint
        )
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setAttribute(Qt.WA_NoSystemBackground)
        self.setAttribute(Qt.WA_TransparentForMouseEvents)  # Make the window click-through

        # Set up the layout
        self.layout = QVBoxLayout()
        self.layout.setContentsMargins(0, 0, 0, 0)
        self.setLayout(self.layout)

        # Create and initialize widgets
        self.icon_label = QLabel()
        self.icon_label.setPixmap(QPixmap(ICON_PATH).scaled(50, 50, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        self.cast_walk_label = QLabel()
        self.cast_walk_label.setPixmap(QPixmap(CAST_WALK_PATH).scaled(50, 50, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        self.cast_roll_label = QLabel()
        self.cast_roll_label.setPixmap(QPixmap(CAST_ROLL_PATH).scaled(50, 50, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        # Add widgets to the layout
        self.layout.addWidget(self.icon_label)
        self.layout.addWidget(self.cast_walk_label)
        self.layout.addWidget(self.cast_roll_label)

        # Hide all widgets initially
        self.icon_label.hide()
        self.cast_walk_label.hide()
        self.cast_roll_label.hide()

        # Apply Windows-specific transparency and click-through styles
        self._apply_windows_clickthrough()

    def _apply_windows_clickthrough(self):
        hwnd = self.winId().__int__()  # Get the window handle
        styles = ctypes.windll.user32.GetWindowLongW(hwnd, ctypes.c_int(-20))
        styles |= 0x80000  # WS_EX_LAYERED
        styles |= 0x20  # WS_EX_TRANSPARENT
        ctypes.windll.user32.SetWindowLongW(hwnd, ctypes.c_int(-20), styles)

    def update_overlay(self, botting, walkCast, rollCast):
        # Update visibility based on the state
        if botting:
            self.icon_label.show()
            self.cast_walk_label.setVisible(walkCast)
            self.cast_roll_label.setVisible(rollCast)
            self.adjustSize()
            self.show()
        else:
            self.hide()

#####

# Function to update the UI
def update_ui():
    global botting, walkCast, rollCast
    try:
        while not event_queue.empty():
            action = event_queue.get_nowait()
            if action == "update":
                overlay.update_overlay(botting, walkCast, rollCast)
    except queue.Empty:
        pass

    # Ensure the overlay reappears when returning to the game
    is_game_active = get_active_window()
    if is_game_active:
        overlay.update_overlay(botting, walkCast, rollCast)
    else:
        overlay.hide()

def get_active_window():
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
                overlay.hide()
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
    app = QApplication(sys.argv)

    # Initialize the overlay
    overlay = Overlay()
    overlay.setGeometry(10, 10, 200, 100)
    overlay.update_overlay(botting, walkCast, rollCast)

    # Start a timer for the UI updates
    timer = QTimer()
    timer.timeout.connect(update_ui)
    timer.start(100)

    # Run the main logic in a separate thread
    import threading
    bot_thread = threading.Thread(target=main, daemon=True)
    bot_thread.start()

    # Start the app
    sys.exit(app.exec())