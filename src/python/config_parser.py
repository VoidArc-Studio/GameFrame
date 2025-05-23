import configparser
import json

def parse_config(config_path):
    config = configparser.ConfigParser()
    config.read(config_path)
    
    settings = {
        "environment": config["General"]["environment"],
        "resolution": config["General"]["resolution"],
        "fullscreen": config["General"].getboolean("fullscreen"),
        "refresh_rate": int(config["General"]["refresh_rate"]),
        "scaling_mode": config["General"]["scaling_mode"],
        "hdr": config["General"].getboolean("hdr"),
        "display_backend": config["General"]["display_backend"],
        "rendering": {
            "backend": config["Rendering"]["backend"],
            "vsync": config["Rendering"].getboolean("vsync"),
            "max_fps": int(config["Rendering"]["max_fps"]),
            "filter": config["Rendering"]["filter"]
        },
        "gpu": {
            "vendor": config["GPU"]["vendor"],
            "opengl_version": config["GPU"]["opengl_version"],
            "vulkan_version": config["GPU"]["vulkan_version"]
        }
    }
    
    return json.dumps(settings)

if __name__ == "__main__":
    config = parse_config("./config/gameframe.conf")
    print(config)
