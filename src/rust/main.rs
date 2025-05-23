use std::fs::File;
use std::io::Write;
use std::process::Command;
use anyhow::Result;
use clap::Parser;
use log::{error, info};
use crate::cli::Cli;
use crate::config::Config;
use crate::isolation::run_in_namespace;
use crate::system::{detect_gpu, detect_resolutions, is_tty, setup_xwayland};
use crate::telemetry::Telemetry;

mod cli;
mod system;
mod isolation;
mod telemetry;
mod config;
mod compositor;
mod bindings;
mod gpu;

fn main() -> Result<()> {
    // Initialize logging
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info"))
        .format(|buf, record| {
            writeln!(buf, "[{}] {}: {}", chrono::Local::now().format("%Y-%m-%d %H:%M:%S"), record.level(), record.args())
        })
        .target(env_logger::Target::Pipe(Box::new(File::create("logs/gameframe.log")?)))
        .init();

    info!("Starting GameFrame");

    // Parse CLI arguments
    let cli = Cli::parse();

    // Detect system state
    let is_tty = is_tty()?;
    if is_tty {
        info!("Running in TTY mode, setting up XWayland");
        setup_xwayland()?;
    }

    // Detect GPU and resolutions
    let gpu_info = detect_gpu()?;
    let resolutions = detect_resolutions()?;
    let refresh_rates = resolutions.refresh_rates;

    // Create configuration
    let mut config = Config {
        environment: cli.environment.unwrap_or("steam-gamepadui".to_string()),
        resolution: cli.resolution.unwrap_or_else(|| resolutions.resolutions.first().cloned().unwrap_or("1920x1080".to_string())),
        fullscreen: true,
        refresh_rate: refresh_rates.first().cloned().unwrap_or(60),
        scaling_mode: "bilinear".to_string(),
        hdr: false,
        display_backend: if is_tty { "wayland".to_string() } else { "x11".to_string() },
        rendering: config::RenderingConfig {
            backend: cli.backend.unwrap_or_else(|| {
                if gpu_info.vendor == "intel" || gpu_info.vulkan_version < "1.2" {
                    "opengl"
                } else {
                    "vulkan"
                }
            }.to_string()),
            vsync: true,
            max_fps: 144,
            filter: "bilinear".to_string(),
        },
        gpu: config::GpuConfig {
            vendor: gpu_info.vendor,
            opengl_version: gpu_info.opengl_version,
            vulkan_version: gpu_info.vulkan_version,
        },
    };

    // Optimize for older GPUs
    if config.gpu.vendor == "intel" {
        config.rendering.backend = "opengl".to_string();
        config.gpu.opengl_version = "4.5".to_string();
        info!("Optimized for Intel GPU: using OpenGL 4.5");
    } else if config.gpu.vendor == "nvidia" && config.gpu.vulkan_version < "1.2" {
        config.rendering.backend = "opengl".to_string();
        config.gpu.opengl_version = "4.6".to_string();
        info!("Optimized for older NVIDIA GPU: using OpenGL 4.6");
    }

    // Generate config file
    let config_json = serde_json::to_string(&config)?;
    let mut config_file = File::create("config/gameframe.conf")?;
    config_file.write_all(config_json.as_bytes())?;
    info!("Generated configuration: config/gameframe.conf");

    // Run Python config parser
    let output = Command::new("python3")
        .arg("./src/python/config_parser.py")
        .output()?;
    if !output.status.success() {
        error!("Failed to parse config: {}", String::from_utf8_lossy(&output.stderr));
        return Err(anyhow::anyhow!("Config parsing failed"));
    }

    // Initialize telemetry
    let mut telemetry = Telemetry::new();

    // Run in isolated namespace
    run_in_namespace(|| {
        // Start C++ compositor
        unsafe {
            let c_config = bindings::Config {
                environment: std::ffi::CString::new(config.environment)?.into_raw(),
                resolution: std::ffi::CString::new(config.resolution)?.into_raw(),
                fullscreen: config.fullscreen,
                refresh_rate: config.refresh_rate,
                scaling_mode: std::ffi::CString::new(config.scaling_mode)?.into_raw(),
                hdr: config.hdr,
                display_backend: std::ffi::CString::new(config.display_backend)?.into_raw(),
                rendering_backend: std::ffi::CString::new(config.rendering.backend)?.into_raw(),
                vsync: config.rendering.vsync,
                max_fps: config.rendering.max_fps,
                filter: std::ffi::CString::new(config.rendering.filter)?.into_raw(),
                gpu_vendor: std::ffi::CString::new(config.gpu.vendor)?.into_raw(),
                opengl_version: std::ffi::CString::new(config.gpu.opengl_version)?.into_raw(),
                vulkan_version: std::ffi::CString::new(config.gpu.vulkan_version)?.into_raw(),
            };

            bindings::start_compositor(&c_config);

            let command = match config.environment.as_str() {
                "gnome" => "gnome-session",
                "kde" => "startplasma-x11",
                "steam-gamepadui" => "steam -gamepadui",
                "heroic" => "heroic",
                "lutris" => "lutris",
                _ => {
                    error!("Unknown environment: {}", config.environment);
                    return Err(anyhow::anyhow!("Invalid environment"));
                }
            };
            let c_command = std::ffi::CString::new(command)?;
            bindings::launch_environment(c_command.as_ptr());

            // Monitor telemetry
            loop {
                telemetry.update();
                if telemetry.frame_count() > 1000 {
                    info!("Telemetry: {:?}", telemetry);
                    telemetry.reset();
                }
                std::thread::sleep(std::time::Duration::from_millis(100));
            }
        }
        Ok(())
    })?;

    unsafe {
        bindings::stop_compositor();
    }
    info!("GameFrame stopped");
    Ok(())
}
