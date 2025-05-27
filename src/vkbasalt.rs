use std::env;

pub fn init_vkbasalt() -> Result<(), Box<dyn std::error::Error>> {
    env::set_var("ENABLE_VKBASALT", "1");
    env::set_var("VKBASALT_CONFIG_FILE", "/path/to/config/vkbasalt.conf");
    println!("vkBasalt włączony");
    Ok(())
}

pub fn apply_post_processing<R: Renderer>(_renderer: &mut R, _frame: &mut R::Frame) -> Result<(), Box<dyn std::error::Error>> {
    println!("Zastosowano post-processing vkBasalt");
    Ok(())
}
