import subprocess
import json
import logging
from typing import Dict, Any

logging.basicConfig(
    filename='logs/gameframe.log',
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s'
)

class SystemInfo:
    @staticmethod
    def get_gpu_info() -> Dict[str, Any]:
        """Detect GPU information."""
        try:
            result = subprocess.run(['bash', './scripts/detect_gpu.sh'], capture_output=True, text=True, check=True)
            gpu_info = json.loads(result.stdout)
            logging.info(f"Detected GPU: {gpu_info['model']} ({gpu_info['vendor']})")
            return gpu_info
        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            logging.error(f"Failed to detect GPU: {e}")
            return {
                "vendor": "unknown",
                "model": "Unknown",
                "driver_version": "Unknown",
                "vulkan_version": "1.0",
                "opengl_version": "2.1"
            }

    @staticmethod
    def get_resolution_info() -> Dict[str, Any]:
        """Detect available resolutions and refresh rates."""
        try:
            result = subprocess.run(['bash', './scripts/detect_resolutions.sh'], capture_output=True, text=True, check=True)
            resolution_info = json.loads(result.stdout)
            logging.info(f"Detected resolutions: {resolution_info['resolutions']}")
            return resolution_info
        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            logging.error(f"Failed to detect resolutions: {e}")
            return {
                "resolutions": ["1920x1080", "1280x720", "2560x1440"],
                "refresh_rates": [60, 75, 120]
            }

    @staticmethod
    def is_tty() -> bool:
        """Check if running in TTY mode."""
        import os
        display = os.getenv('DISPLAY')
        wayland_display = os.getenv('WAYLAND_DISPLAY')
        is_tty = not display and not wayland_display
        logging.info(f"TTY mode: {is_tty}")
        return is_tty
