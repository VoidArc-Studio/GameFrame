use std::process::Command;

pub fn start_gamemode() -> Result<(), Box<dyn std::error::Error>> {
    Command::new("gamemoderun")
        .spawn()
        .expect("Nie udało się uruchomić GameMode");
    println!("GameMode włączony");
    Ok(())
}

pub fn stop_gamemode() -> Result<(), Box<dyn std::error::Error>> {
    // Placeholder: Zatrzymanie GameMode (może wymagać zabicia procesu)
    Ok(())
}
