import json
import os
import logging
from typing import Dict, Any
from pathlib import Path

# Setup logging
logging.basicConfig(
    filename='logs/gameframe.log',
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s'
)

class ConfigParser:
    DEFAULT_CONFIG = {
        "environment": "steam-gamepadui",
        "resolution": "1920x1080",
        "fullscreen": True,
        "refresh_rate": 60,
        "scaling_mode": "bilinear",
        "hdr": False,
        "display_backend": "wayland",
        "rendering": {
            "backend": "vulkan",
            "vsync": True,
            "max_fps": 144,
            "filter": "bilinear"
        },
        "gpu": {
            "vendor": "unknown",
            "opengl_version": "2.1",
            "vulkan_version": "1.0"
        }
    }

    VALID_ENVIRONMENTS = {"steam-gamepadui", "gnome", "kde", "heroic", "lutris"}
    VALID_BACKENDS = {"vulkan", "opengl"}
    VALID_SCALING_MODES = {"bilinear", "fsr"}
    VALID_RESOLUTIONS = {"1920x1080", "1280x720", "2560x1440", "3840x2160"}

    def __init__(self, config_path: str = "config/gameframe.conf"):
        self.config_path = Path(config_path)
        self.profiles_dir = Path("config/profiles")
        self.profiles_dir.mkdir(parents=True, exist_ok=True)

    def validate_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Validate and normalize configuration."""
        validated = self.DEFAULT_CONFIG.copy()

        # General settings
        validated["environment"] = config.get("environment", validated["environment"])
        if validated["environment"] not in self.VALID_ENVIRONMENTS:
            logging.warning(f"Invalid environment: {validated['environment']}, defaulting to steam-gamepadui")
            validated["environment"] = "steam-gamepadui"

        validated["resolution"] = config.get("resolution", validated["resolution"])
        if validated["resolution"] not in self.VALID_RESOLUTIONS:
            logging.warning(f"Invalid resolution: {validated['resolution']}, defaulting to 1920x1080")
            validated["resolution"] = "1920x1080"

        validated["fullscreen"] = config.get("fullscreen", validated["fullscreen"])
        validated["refresh_rate"] = config.get("refresh_rate", validated["refresh_rate"])
        if not isinstance(validated["refresh_rate"], int) or validated["refresh_rate"] < 30:
            logging.warning(f"Invalid refresh rate: {validated['refresh_rate']}, defaulting to 60")
            validated["refresh_rate"] = 60

        validated["scaling_mode"] = config.get("scaling_mode", validated["scaling_mode"])
        if validated["scaling_mode"] not in self.VALID_SCALING_MODES:
            logging.warning(f"Invalid scaling mode: {validated['scaling_mode']}, defaulting to bilinear")
            validated["scaling_mode"] = "bilinear"

        validated["hdr"] = config.get("hdr", validated["hdr"])
        validated["display_backend"] = config.get("display_backend", validated["display_backend"])

        # Rendering settings
        rendering = config.get("rendering", {})
        validated["rendering"]["backend"] = rendering.get("backend", validated["rendering"]["backend"])
        if validated["rendering"]["backend"] not in self.VALID_BACKENDS:
            logging.warning(f"Invalid backend: {validated['rendering']['backend']}, defaulting to vulkan")
            validated["rendering"]["backend"] = "vulkan"

        validated["rendering"]["vsync"] = rendering.get("vsync", validated["rendering"]["vsync"])
        validated["rendering"]["max_fps"] = rendering.get("max_fps", validated["rendering"]["max_fps"])
        if not isinstance(validated["rendering"]["max_fps"], int) or validated["rendering"]["max_fps"] < 30:
            logging.warning(f"Invalid max_fps: {validated['rendering']['max_fps']}, defaulting to 144")
            validated["rendering"]["max_fps"] = 144

        validated["rendering"]["filter"] = rendering.get("filter", validated["rendering"]["filter"])

        # GPU settings
        gpu = config.get("gpu", {})
        validated["gpu"]["vendor"] = gpu.get("vendor", validated["gpu"]["vendor"])
        validated["gpu"]["opengl_version"] = gpu.get("opengl_version", validated["gpu"]["opengl_version"])
        validated["gpu"]["vulkan_version"] = gpu.get("vulkan_version", validated["gpu"]["vulkan_version"])

        # Optimize for older GPUs
        if validated["gpu"]["vendor"] == "intel" or validated["gpu"]["vulkan_version"] < "1.2":
            validated["rendering"]["backend"] = "opengl"
            validated["resolution"] = "1280x720"
            logging.info("Optimized for older GPU: using OpenGL and 1280x720")

        return validated

    def load_config(self) -> Dict[str, Any]:
        """Load and validate configuration from file."""
        try:
            with self.config_path.open('r') as f:
                config = json.load(f)
            validated_config = self.validate_config(config)
            logging.info(f"Loaded and validated config from {self.config_path}")
            return validated_config
        except FileNotFoundError:
            logging.warning(f"Config file {self.config_path} not found, using defaults")
            return self.DEFAULT_CONFIG
        except json.JSONDecodeError as e:
            logging.error(f"Invalid JSON in {self.config_path}: {e}")
            return self.DEFAULT_CONFIG

    def save_config(self, config: Dict[str, Any]) -> None:
        """Save validated configuration to file."""
        validated_config = self.validate_config(config)
        try:
            with self.config_path.open('w') as f:
                json.dump(validated_config, f, indent=2)
            logging.info(f"Saved config to {self.config_path}")
        except Exception as e:
            logging.error(f"Failed to save config to {self.config_path}: {e}")
            raise

    def save_profile(self, profile_name: str, config: Dict[str, Any]) -> None:
        """Save configuration as a profile."""
        profile_path = self.profiles_dir / f"{profile_name}.json"
        validated_config = self.validate_config(config)
        try:
            with profile_path.open('w') as f:
                json.dump(validated_config, f, indent=2)
            logging.info(f"Saved profile {profile_name} to {profile_path}")
        except Exception as e:
            logging.error(f"Failed to save profile {profile_name}: {e}")
            raise

    def load_profile(self, profile_name: str) -> Dict[str, Any]:
        """Load configuration from a profile."""
        profile_path = self.profiles_dir / f"{profile_name}.json"
        try:
            with profile_path.open('r') as f:
                config = json.load(f)
            validated_config = self.validate_config(config)
            logging.info(f"Loaded profile {profile_name} from {profile_path}")
            return validated_config
        except FileNotFoundError:
            logging.warning(f"Profile {profile_name} not found")
            return self.DEFAULT_CONFIG
        except json.JSONDecodeError as e:
            logging.error(f"Invalid JSON in profile {profile_name}: {e}")
            return self.DEFAULT_CONFIG

    def get_profiles(self) -> list:
        """List available profiles."""
        try:
            return [p.stem for p in self.profiles_dir.glob("*.json")]
        except Exception as e:
            logging.error(f"Failed to list profiles: {e}")
            return []

def main():
    parser = ConfigParser()
    config = parser.load_config()
    print(json.dumps(config, indent=2))

if __name__ == "__main__":
    main()
