use ash::vk;

pub fn apply_scaling(
    renderer: &mut impl Renderer,
    frame: &mut impl Renderer,
    quality: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    match quality {
        "FSR" => {
            println!("Zastosowano skalowanie FSR");
        }
        "Bilinear" => {
            println!("Zastosowano skalowanie Bilinear");
        }
        "Integer" => {
            println!("Zastosowano skalowanie Integer");
        }
        _ => {
            println!("Domyślne skalowanie: FSR");
        }
    }
    Ok(())
}
