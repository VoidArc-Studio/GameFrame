import json
import logging
import subprocess
from typing import Dict, Any
import inquirer
from config_parser import ConfigParser
from system_info import SystemInfo

logging.basicConfig(
    filename='logs/gameframe.log',
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s'
)

class TtyUi:
    def __init__(self):
        self.config_parser = ConfigParser()
        self.system_info = SystemInfo()

    def run(self) -> None:
        """Run the TTY UI."""
        gpu_info = self.system_info.get_gpu_info()
        resolution_info = self.system_info.get_resolution_info()

        questions = [
            inquirer.List('environment',
                         message="Select environment",
                         choices=['steam-gamepadui', 'gnome', 'kde', 'heroic', 'lutris'],
                         default='steam-gamepadui'),
            inquirer.List('backend',
                         message="Select rendering backend",
                         choices=['vulkan', 'opengl'],
                         default='opengl' if gpu_info['vendor'] == 'intel' or gpu_info['vulkan_version'] < '1.2' else 'vulkan'),
            inquirer.List('resolution',
                         message="Select resolution",
                         choices=resolution_info['resolutions'],
                         default='1920x1080'),
            inquirer.List('refresh_rate',
                         message="Select refresh rate",
                         choices=[f"{rate} Hz" for rate in resolution_info['refresh_rates']],
                         default='60 Hz'),
            inquirer.List('scaling_mode',
                         message="Select scaling mode",
                         choices=['bilinear', 'fsr'],
                         default='bilinear'),
            inquirer.Confirm('hdr',
                           message="Enable HDR?",
                           default=False),
            inquirer.Confirm('vsync',
                           message="Enable VSync?",
                           default=True),
            inquirer.Text('max_fps',
                         message="Max FPS",
                         default='144',
                         validate=lambda _, x: x.isdigit() and int(x) > 0)
        ]

        answers = inquirer.prompt(questions)
        if not answers:
            logging.error("TTY UI cancelled")
            return

        config = {
            "environment": answers['environment'],
            "resolution": answers['resolution'],
            "fullscreen": True,
            "refresh_rate": int(answers['refresh_rate'].split()[0]),
            "scaling_mode": answers['scaling_mode'],
            "hdr": answers['hdr'],
            "display_backend": "wayland",
            "rendering": {
                "backend": answers['backend'],
                "vsync": answers['vsync'],
                "max_fps": int(answers['max_fps']),
                "filter": answers['scaling_mode']
            },
            "gpu": {
                "vendor": gpu_info['vendor'],
                "opengl_version": gpu_info['opengl_version'],
                "vulkan_version": gpu_info['vulkan_version']
            }
        }

        self.config_parser.save_config(config)
        logging.info("Saved TTY UI configuration")

        launch = inquirer.prompt([inquirer.Confirm('launch', message="Launch GameFrame now?", default=True)])
        if launch and launch['launch']:
            try:
                subprocess.run(['bash', './scripts/launch.sh'], check=True)
                logging.info("GameFrame launched from TTY UI")
            except subprocess.CalledProcessError as e:
                logging.error(f"Failed to launch GameFrame: {e}")

def main():
    ui = TtyUi()
    ui.run()

if __name__ == "__main__":
    main()
