import subprocess
import logging
from typing import Callable, Any

logging.basicConfig(
    filename='logs/gameframe.log',
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s'
)

class Isolation:
    @staticmethod
    def run_isolated(command: list, use_firejail: bool = False) -> None:
        """Run a command in an isolated environment."""
        try:
            if use_firejail and subprocess.run(['which', 'firejail'], capture_output=True).returncode == 0:
                cmd = ['firejail', '--noprofile', '--net=none'] + command
                logging.info(f"Running isolated with firejail: {cmd}")
            else:
                cmd = ['unshare', '-nmupf', '--mount-proc'] + command
                logging.info(f"Running isolated with unshare: {cmd}")
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to run isolated command: {e}")
            raise
        except FileNotFoundError:
            logging.warning("Isolation tools (firejail/unshare) not found, running without isolation")
            subprocess.run(command, check=True)
