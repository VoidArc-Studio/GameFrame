import json
import logging
import time
from typing import Dict, Any
import socket
import struct

logging.basicConfig(
    filename='logs/gameframe.log',
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s'
)

class Telemetry:
    def __init__(self, ipc_path: str = "/tmp/gameframe-telemetry"):
        self.ipc_path = ipc_path
        self.sock = None

    def connect(self) -> None:
        """Connect to Rust telemetry server via Unix socket."""
        try:
            self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            self.sock.connect(self.ipc_path)
            logging.info(f"Connected to telemetry server at {self.ipc_path}")
        except Exception as e:
            logging.error(f"Failed to connect to telemetry server: {e}")
            raise

    def get_telemetry(self) -> Dict[str, Any]:
        """Fetch telemetry data."""
        try:
            if not self.sock:
                self.connect()
            self.sock.send(b"get-telemetry\n")
            data = self.sock.recv(1024).decode('utf-8')
            telemetry = json.loads(data)
            logging.info(f"Telemetry: Frames {telemetry['frame_count']}, Avg Frame Time {telemetry['avg_frame_time']:.2f} ms")
            return telemetry
        except Exception as e:
            logging.error(f"Failed to fetch telemetry: {e}")
            return {"frame_count": 0, "avg_frame_time": 0.0}

    def close(self) -> None:
        """Close the telemetry connection."""
        if self.sock:
            self.sock.close()
            logging.info("Closed telemetry connection")
