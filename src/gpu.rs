use sysinfo::{System, SystemExt};
use ash::vk;

pub fn detect_gpu() -> String {
    let output = std::process::Command::new("lspci")
        .arg("-v")
        .output()
        .expect("Nie można uruchomić lspci");
    let output_str = String::from_utf8_lossy(&output.stdout);
    if output_str.contains("NVIDIA") {
        "NVIDIA".to_string()
    } else if output_str.contains("AMD") {
        "AMD".to_string()
    } else if output_str.contains("Intel") {
        "Intel".to_string()
    } else {
        "Unknown".to_string()
    }
}

pub fn select_renderer(gpu: &str) -> Result<(), Box<dyn std::error::Error>> {
    match gpu {
        "NVIDIA" | "AMD" => {
            println!("Wybrano renderer Vulkan dla {}", gpu);
        }
        "Intel" => {
            println!("Wybrano renderer OpenGL dla {}", gpu);
        }
        _ => {
            println!("Nieznany GPU, domyślny renderer: Vulkan");
        }
    }
    Ok(())
}
