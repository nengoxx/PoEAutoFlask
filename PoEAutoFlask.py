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

from PySide6.QtWidgets import QApplication, QLabel, QWidget, QVBoxLayout, QHBoxLayout
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
hold_threshold = 2  # seconds

#Cast after roll
rollCast=False

#Auto flasks
autoManaFlask=False

# Coordinates of the pixel to monitor
pixel_x = 938  # Replace with the actual x-coordinate
pixel_y = 368  # Replace with the actual y-coordinate
# Bright red color (R, G, B)
blue_mana = [(28, 74, 177),(25, 67, 146),(24, 63, 145),(19, 51, 117)]
blue_mana_range = {
    'red': (16, 32),
    'green': (45, 80),
    'blue': (115, 185)
}
green_life = (255, 0, 0)
green_life_range = {
    'red': (29, 31),
    'green': (143, 145),
    'blue': (44, 45)
}
press_interval_manaf = 4 # Time interval to wait before pressing the key again (in seconds)
last_press_time_manaf = 0 # Variable to keep track of the last time the key was pressed

#Key list for auto rotation
keyList=['shift+e','shift+r','shift+2','shift+q']

#Key list for skills
commandMinions_s="1"
roll_s="space"
life_flask_s="2"
mana_flask_s="3"

#Toggle buttons
walkCast_btn='0'
rollCast_btn='9'
manaFlask_btn='8'

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
icon_size=50
CAST_WALK_PATH = './img/castWalk.png'
CAST_ROLL_PATH = './img/castRoll.png'
MANA_FLASK_PATH = './img/manaFlask.png'
extra_icon_size=25

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
        #self.layout = QVBoxLayout()  # Vertical layout
        # or
        self.layout = QHBoxLayout()  # Horizontal layout
        self.layout.setContentsMargins(0, 0, 0, 0)
        #self.layout.setSpacing(10)  # Change spacing between widgets
        self.layout.setAlignment(Qt.AlignCenter)  # Center the layout
        self.setLayout(self.layout)

        # Create and initialize widgets
        self.icon_label = QLabel()
        self.icon_label.setPixmap(QPixmap(ICON_PATH).scaled(icon_size, icon_size, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        self.cast_walk_label = QLabel()
        self.cast_walk_label.setPixmap(QPixmap(CAST_WALK_PATH).scaled(extra_icon_size, extra_icon_size, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        self.cast_roll_label = QLabel()
        self.cast_roll_label.setPixmap(QPixmap(CAST_ROLL_PATH).scaled(extra_icon_size, extra_icon_size, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        self.flask_mana_label = QLabel()
        self.flask_mana_label.setPixmap(QPixmap(MANA_FLASK_PATH).scaled(extra_icon_size, extra_icon_size, Qt.KeepAspectRatio, Qt.SmoothTransformation))

        # Add widgets to the layout
        self.layout.addWidget(self.icon_label)
        self.layout.addWidget(self.cast_walk_label)
        self.layout.addWidget(self.cast_roll_label)
        self.layout.addWidget(self.flask_mana_label)

        # Hide all widgets initially
        self.icon_label.hide()
        self.cast_walk_label.hide()
        self.cast_roll_label.hide()
        self.flask_mana_label.hide()

        # Apply Windows-specific transparency and click-through styles
        self._apply_windows_clickthrough()

        # Set the overlay position to the top middle of the screen
        screen_geometry = QGuiApplication.primaryScreen().availableGeometry()
        overlay_width = self.layout.sizeHint().width()
        overlay_height = self.layout.sizeHint().height()
        x_position = (screen_geometry.width() - overlay_width) // 2
        y_position = 0  # Top of the screen
        self.setGeometry(x_position, y_position, overlay_width, overlay_height)

    def _apply_windows_clickthrough(self):
        hwnd = self.winId().__int__()  # Get the window handle
        styles = ctypes.windll.user32.GetWindowLongW(hwnd, ctypes.c_int(-20))
        styles |= 0x80000  # WS_EX_LAYERED
        styles |= 0x20  # WS_EX_TRANSPARENT
        ctypes.windll.user32.SetWindowLongW(hwnd, ctypes.c_int(-20), styles)

    def update_overlay(self, botting, walkCast, rollCast, autoManaFlask):
        # Update visibility based on the state
        if botting:
            self.icon_label.show()
            self.cast_walk_label.setVisible(walkCast)
            self.cast_roll_label.setVisible(rollCast)
            self.flask_mana_label.setVisible(autoManaFlask)
            self.adjustSize()
            self.show()
        else:
            self.hide()

#####

# Function to update the UI
def update_ui():
    global botting, walkCast, rollCast, autoManaFlask
    try:
        while not event_queue.empty():
            action = event_queue.get_nowait()
            if action == "update":
                overlay.update_overlay(botting, walkCast, rollCast, autoManaFlask)
    except queue.Empty:
        pass

    # Ensure the overlay reappears when returning to the game
    is_game_active = get_active_window()
    if is_game_active:
        overlay.update_overlay(botting, walkCast, rollCast, autoManaFlask)
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

#Mana flask
def toggleAutoManaFlask(kb_event_info):
    global autoManaFlask
    autoManaFlask = not autoManaFlask
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

def is_color_in_range(pixel_color, color_range):
    red, green, blue = pixel_color
    return (color_range['red'][0] <= red <= color_range['red'][1] and
            color_range['green'][0] <= green <= color_range['green'][1] and
            color_range['blue'][0] <= blue <= color_range['blue'][1])

def monitor_pixel_color():
    global last_press_time_manaf
    while True:
        if not botting or not get_active_window() or not autoManaFlask:
            time.sleep(1)
            continue
        # Get the color of the pixel
        pixel_color = pyautogui.pixel(pixel_x, pixel_y)

        # Check if the color has changed from bright red
        #if pixel_color != blue_mana:
        #if pixel_color not in blue_mana:
        if not is_color_in_range(pixel_color, blue_mana_range):
            current_time = time.time()
            # Check if the press interval has passed
            if current_time - last_press_time_manaf >= press_interval_manaf:
                keyboard.send(mana_flask_s)
                # keyboard.press(mana_flask_s)
                # sleep(randint(10, 50)/1000)
                # keyboard.release(mana_flask_s)
                last_press_time_manaf = current_time

        # Sleep for a short duration to avoid high CPU usage
        time.sleep(0.1)

""" def monitor_pixel_color_log():
    global last_press_time_manaf
    while True:
        if not botting or not get_active_window() or not autoManaFlask:
            time.sleep(1)
            continue
        # Get the color of the pixel
        pixel_color = pyautogui.pixel(pixel_x, pixel_y)

        # Check if the color has changed from bright red
        if not is_color_in_range(pixel_color, blue_mana_range):
            current_time = time.time()
            time_since_last_press = current_time - last_press_time_manaf
            print(f"Current Time: {current_time}, Last Press Time: {last_press_time_manaf}, Time Since Last Press: {time_since_last_press}, Press Interval: {press_interval_manaf}")
            if time_since_last_press >= press_interval_manaf:
                print("Pressing mana flask")
                keyboard.send(mana_flask_s)
                last_press_time_manaf = current_time
            else:
                print("Not pressing yet, time remaining:", press_interval_manaf - time_since_last_press)
        else:
            print("Pixel color is within range, no action needed.")

        # Sleep for a short duration to avoid high CPU usage
        time.sleep(0.1)

def monitor_pixel_color_threaded():
    global last_press_time_manaf
    while True:
        if not botting or not get_active_window() or not autoManaFlask:
            time.sleep(1)
            continue
        # Get the color of the pixel
        pixel_color = pyautogui.pixel(pixel_x, pixel_y)

        # Check if the color has changed from bright red
        if not is_color_in_range(pixel_color, blue_mana_range):
            if threading.active_count() > 1:
                threading.active_count() - 1
            threading.Timer(press_interval_manaf - 0.1, press_mana_flask).start()

def press_mana_flask():
    global last_press_time_manaf
    keyboard.send(mana_flask_s)
    # keyboard.press(mana_flask_s)
    # sleep(randint(10, 50)/1000)
    # keyboard.release(mana_flask_s)
    last_press_time_manaf = time.time() """

def main():
    global botting
    if __name__== "__main__" :
        keyboard.on_press_key('º',switchBot)
        keyboard.on_press_key('enter',stopBot)
        listener = mouse.Listener(on_click=on_click)
        listener.start()
        keyboard.on_press_key(walkCast_btn,toggleWalkCast)
        keyboard.on_press_key(rollCast_btn,toggleRollCast)
        keyboard.on_press_key(manaFlask_btn,toggleAutoManaFlask)
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
    #overlay.setGeometry(10, 10, 200, 100) #load from file?
    overlay.update_overlay(botting, walkCast, rollCast, autoManaFlask)

    # Start a timer for the UI updates
    timer = QTimer()
    timer.timeout.connect(update_ui)
    timer.start(100)

    # Run the main logic in a separate thread
    bot_thread = threading.Thread(target=main, daemon=True)
    bot_thread.start()

    # Start the monitoring function in a separate thread
    monitor_thread = threading.Thread(target=monitor_pixel_color, daemon=True)
    monitor_thread.start()

    # Start the app
    sys.exit(app.exec())