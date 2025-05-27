use sysinfo::{System, SystemExt};
use crate::compositor::GameFrameCompositor;

pub fn optimize_game(compositor: &GameFrameCompositor) -> Result<(), Box<dyn std::error::Error>> {
    let mut sys = System::new_all();
    sys.refresh_all();

    let cpu_usage = sys.global_cpu_info().cpu_usage();
    let gpu_usage = get_gpu_usage();
    let fps = get_fps();

    if cpu_usage > 80.0 || gpu_usage > 80.0 {
        println!("Optymalizacja: Zmniejsz rozdzielczość");
        compositor.resize(Size::from((1280, 720)));
    } else if fps < 30.0 {
        println!("Optymalizacja: Zmień skalowanie na {}", compositor.quality());
    }

    Ok(())
}

fn get_gpu_usage() -> f32 {
    50.0 // Placeholder
}

fn get_fps() -> f32 {
    60.0 // Placeholder
}
