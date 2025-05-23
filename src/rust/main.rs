use std::process::Command;
use std::fs;

mod compositor;
mod config;
mod gpu;

fn main() {
    // Read configuration via Python parser
    let output = Command::new("python3")
        .arg("./src/python/config_parser.py")
        .output()
        .expect("Failed to parse config");
    let config_json = String::from_utf8(output.stdout).expect("Invalid config output");
    let config: config::Config = serde_json::from_str(&config_json).expect("Failed to deserialize config");

    // Initialize compositor
    let mut compositor = compositor::Compositor::new(&config);
    
    // Launch environment based on config
    match config.environment.as_str() {
        "gnome" => compositor.launch("gnome-session"),
        "kde" => compositor.launch("startplasma-x11"),
        "steam-gamepadui" => compositor.launch("steam -gamepadui"),
        "heroic" => compositor.launch("heroic"),
        "lutris" => compositor.launch("lutris"),
        _ => eprintln!("Unknown environment: {}", config.environment),
    }

    // Start rendering loop
    compositor.run();
}
