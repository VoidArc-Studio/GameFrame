use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
pub struct Config {
    pub environment: String,
    pub resolution: String,
    pub fullscreen: bool,
    pub refresh_rate: u32,
    pub scaling_mode: String,
    pub hdr: bool,
    pub display_backend: String,
    pub rendering: RenderingConfig,
    pub gpu: GpuConfig,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct RenderingConfig {
    pub backend: String,
    pub vsync: bool,
    pub max_fps: u32,
    pub filter: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct GpuConfig {
    pub vendor: String,
    pub opengl_version: String,
    pub vulkan_version: String,
}
