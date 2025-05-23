use std::ffi::{c_char, c_void};

#[repr(C)]
pub struct Config {
    pub environment: *mut c_char,
    pub resolution: *mut c_char,
    pub fullscreen: bool,
    pub refresh_rate: u32,
    pub scaling_mode: *mut c_char,
    pub hdr: bool,
    pub display_backend: *mut c_char,
    pub rendering_backend: *mut c_char,
    pub vsync: bool,
    pub max_fps: u32,
    pub filter: *mut c_char,
    pub gpu_vendor: *mut c_char,
    pub opengl_version: *mut c_char,
    pub vulkan_version: *mut c_char,
}

extern "C" {
    pub fn start_compositor(config: *const Config);
    pub fn stop_compositor();
    pub fn launch_environment(command: *const c_char);
    pub fn start_frame_timer(max_fps: u32, refresh_rate: u32);
    pub fn stop_frame_timer();
    pub fn get_frame_count() -> u64;
    pub fn get_average_frame_time() -> f64;
}
