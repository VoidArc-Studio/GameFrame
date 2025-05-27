use egui::{CentralPanel, Context};
use smithay::backend::renderer::Renderer;

pub struct GameFrameGui {
    scaling_method: String,
    fps_limit: i32,
}

impl GameFrameGui {
    pub fn new(quality: String) -> Self {
        GameFrameGui {
            scaling_method: quality,
            fps_limit: 60,
        }
    }

    pub fn render<R: Renderer>(&mut self, _renderer: &mut R) -> Result<(), Box<dyn std::error::Error>> {
        let ctx = Context::default();
        CentralPanel::default().show(&ctx, |ui| {
            ui.heading("GameFrame - Lossless Scaling");
            ui.label("Metoda skalowania:");
            egui::ComboBox::from_label("Wybierz")
                .selected_text(&self.scaling_method)
                .show_ui(ui, |ui| {
                    ui.selectable_value(&mut self.scaling_method, "FSR".to_string(), "FSR");
                    ui.selectable_value(&mut self.scaling_method, "Bilinear".to_string(), "Bilinear");
                    ui.selectable_value(&mut self.scaling_method, "Integer".to_string(), "Integer");
                });
            ui.label("Limit FPS:");
            egui::ComboBox::from_label("Wybierz")
                .selected_text(format!("{}", self.fps_limit))
                .show_ui(ui, |ui| {
                    ui.selectable_value(&mut self.fps_limit, 30, "30");
                    ui.selectable_value(&mut self.fps_limit, 60, "60");
                    ui.selectable_value(&mut self.fps_limit, 120, "120");
                });
            if ui.button("Zastosuj").clicked() {
                println!("Zastosowano: Skalowanie: {}, FPS: {}", self.scaling_method, self.fps_limit);
            }
        });
        Ok(())
    }
}
