use anyhow::Result;
use std::process::Command;
use serde::Deserialize;

#[derive(Deserialize)]
pub struct GpuInfo {
    pub vendor: String,
    pub model: String,
    pub driver_version: String,
    pub vulkan_version: String,
    pub opengl_version: String,
}

#[derive(Deserialize)]
pub struct ResolutionInfo {
    pub resolutions: Vec<String>,
    pub refresh_rates: Vec<u32>,
}

pub fn is_tty() -> Result<bool> {
    Ok(std::env::var("DISPLAY").is_err() && std::env::var("WAYLAND_DISPLAY").is_err())
}

pub fn detect_gpu() -> Result<GpuInfo> {
    let output = Command::new("bash")
        .arg("./scripts/detect_gpu.sh")
        .output()?;
    if !output.status.success() {
        return Err(anyhow::anyhow!("Failed to detect GPU: {}", String::from_utf8_lossy(&output.stderr)));
    }
    let gpu_info: GpuInfo = serde_json::from_slice(&output.stdout)?;
    Ok(gpu_info)
}

pub fn detect_resolutions() -> Result<ResolutionInfo> {
    let output = Command::new("bash")
        .arg("./scripts/detect_resolutions.sh")
        .output()?;
    if !output.status.success() {
        return Err(anyhow::anyhow!("Failed to detect resolutions: {}", String::from_utf8_lossy(&output.stderr)));
    }
    let resolution_info: ResolutionInfo = serde_json::from_slice(&output.stdout)?;
    Ok(resolution_info)
}

pub fn setup_xwayland() -> Result<()> {
    let output = Command::new("bash")
        .arg("./scripts/setup_xwayland.sh")
        .output()?;
    if !output.status.success() {
        return Err(anyhow::anyhow!("Failed to set up XWayland: {}", String::from_utf8_lossy(&output.stderr)));
    }
    Ok(())
}
