use std::env;

pub fn init_mangohud() -> Result<(), Box<dyn std::error::Error>> {
    env::set_var("MANGOHUD", "1");
    env::set_var("MANGOHUD_CONFIG_FILE", "/home/user/.config/gameframe/mangohud.conf");
    println!("MangoHud włączony");
    Ok(())
}

pub fn update_hud() -> Result<(), Box<dyn std::error::Error>> {
    println!("Aktualizacja MangoHud");
    Ok(())
}
