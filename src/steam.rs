use std::process::Command;

pub fn launch_application(app: &str) -> Result<(), Box<dyn std::error::Error>> {
    let mut args = app.split_whitespace();
    let cmd = args.next().unwrap_or("steam");
    let cmd_args: Vec<&str> = args.collect();
    Command::new(cmd)
        .args(cmd_args)
        .env("SDL_VIDEODRIVER", "wayland")
        .env("STEAM_FORCE_DESKTOPUI_SCALING", "1")
        .spawn()
        .expect("Nie udało się uruchomić aplikacji");
    Ok(())
}
