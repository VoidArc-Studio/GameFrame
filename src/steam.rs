use std::process::Command;

pub fn launch_steam() -> Result<(), Box<dyn std::error::Error>> {
    Command::new("steam")
        .arg("-gamepadui")
        .env("SDL_VIDEODRIVER", "wayland")
        .spawn()
        .expect("Nie udało się uruchomić Steam");
    Ok(())
}
