pub fn configure_opengl(vendor: &str) -> String {
    match vendor {
        "intel" => "4.5".to_string(),
        "nvidia" => "4.6".to_string(),
        _ => "4.5".to_string(),
    }
}
