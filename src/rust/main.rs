use std::process::Command;
use std::ffi::CString;

mod config;
mod bindings;

fn main() {
    let output = Command::new("python3")
        .arg("./src/python/config_parser.py")
        .output()
        .expect("Failed to parse config");
    let config_json = String::from_utf8(output.stdout).expect("Invalid config output");
    let config: config::Config = serde_json::from_str(&config_json).expect("Failed to deserialize config");

    let c_config = bindings::Config {
        environment: CString::new(config.environment).unwrap().into_raw(),
        resolution: CString::new(config.resolution).unwrap().into_raw(),
        fullscreen: config.fullscreen,
        refresh_rate: config.refresh_rate,
        scaling_mode: CString::new(config.scaling_mode).unwrap().into_raw(),
        hdr: config.hdr,
        display_backend: CString::new(config.display_backend).unwrap().into_raw(),
        rendering_backend: CString::new(config.rendering.backend).unwrap().into_raw(),
        vsync: config.rendering.vsync,
        max_fps: config.rendering.max_fps,
        filter: CString::new(config.rendering.filter).unwrap().into_raw(),
        gpu_vendor: CString::new(config.gpu.vendor).unwrap().into_raw(),
        opengl_version: CString::new(config.gpu.opengl_version).unwrap().into_raw(),
        vulkan_version: CString::new(config.gpu.vulkan_version).unwrap().into_raw(),
    };

    unsafe {
        bindings::start_compositor(&c_config);

        let command = match config.environment.as_str() {
            "gnome" => "gnome-session",
            "kde" => "startplasma-x11",
            "steam-gamepadui" => "steam -gamepadui",
            "heroic" => "heroic",
            "lutris" => "lutris",
            _ => panic!("Unknown environment"),
        };
        let c_command = CString::new(command).unwrap();
        bindings::launch_environment(c_command.as_ptr());

        // Keep running until interrupted
        std::thread::sleep(std::time::Duration::from_secs(3600));
        bindings::stop_compositor();
    }
}
