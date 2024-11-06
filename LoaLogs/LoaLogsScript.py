import threading
import time
import psutil
import subprocess
import pystray
from pystray import MenuItem as item
from PIL import Image, ImageDraw

class App:
    def __init__(self):
        self.running = True
        self.thread = threading.Thread(target=self.monitor_processes, daemon=True)
        self.thread.start()

    def manage_loalogs(self):
        if self.is_process_running("LOSTARK.exe"):
            if self.is_process_running("LOA Logs.exe"):
                return
            self.launch_program(r"C:\Users\jassz\AppData\Local\LOA Logs\LOA Logs.exe")
            print('LOA Logs launched')
        else:
            if self.is_process_running("LOA Logs.exe"):
                self.kill_program("LOA Logs.exe")

    def is_process_running(self, process_name):
        for proc in psutil.process_iter(['pid', 'name']):
            if proc.info['name'] == process_name:
                return True
        return False

    def launch_program(self, program_path):
        try:
            subprocess.Popen([program_path])
        except Exception as e:
            print(f"Failed to launch {program_path}: {e}")

    def kill_program(self, process_name):
        for proc in psutil.process_iter(['pid', 'name']):
            try:
                if proc.info['name'] == process_name:
                    proc.terminate()
                    proc.wait(timeout=3)
                    if proc.is_running():
                        proc.kill()
                    print(f"Process {process_name} with PID {proc.info['pid']} killed.")
                    return True
            except Exception as e:
                print(f"Failed to kill {process_name}: {e}")

    def monitor_processes(self):
        while self.running:
            self.manage_loalogs()
            time.sleep(30)

    def stop(self):
        self.running = False

# Function to create an image for the icon
def create_image(width, height, color1, color2):
    image = Image.new('RGB', (width, height), color1)
    dc = ImageDraw.Draw(image)
    dc.rectangle(
        (width // 2, 0, width, height // 2),
        fill=color2)
    dc.rectangle(
        (0, height // 2, width // 2, height),
        fill=color2)
    return image

# Function to stop the program
def on_quit(icon, item):
    app.stop()
    icon.stop()
    print("Quitting the application")

# Function to set up the icon and menu
def setup(icon):
    icon.visible = True

# Create an image for the icon
icon_image = create_image(64, 64, 'black', 'white')

# Create the system tray icon
icon = pystray.Icon("test_icon", icon_image, "LoaLogsScript", menu=pystray.Menu(
    item('Quit', on_quit)
))

# Create an instance of App
app = App()

# Run the icon setup
icon.run(setup)
