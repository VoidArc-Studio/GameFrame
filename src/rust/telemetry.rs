use crate::bindings;
use std::fmt;

#[derive(Debug)]
pub struct Telemetry {
    frame_count: u64,
    avg_frame_time: f64,
}

impl Telemetry {
    pub fn new() -> Self {
        Telemetry {
            frame_count: 0,
            avg_frame_time: 0.0,
        }
    }

    pub fn update(&mut self) {
        unsafe {
            self.frame_count = bindings::get_frame_count();
            self.avg_frame_time = bindings::get_average_frame_time();
        }
    }

    pub fn reset(&mut self) {
        self.frame_count = 0;
        self.avg_frame_time = 0.0;
    }

    pub fn frame_count(&self) -> u64 {
        self.frame_count
    }
}

impl fmt::Display for Telemetry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Frames: {}, Avg Frame Time: {:.2} ms", self.frame_count, self.avg_frame_time)
    }
}
