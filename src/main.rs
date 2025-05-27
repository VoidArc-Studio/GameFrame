use smithay::{
    backend::{
        renderer::{Format, ImportAll, Renderer},
        winit::{WinitBackend, WinitEvent},
        x11::{X11Backend, X11Event},
    },
    desktop::Window,
    reexports::wayland_server::Display,
    utils::{Rectangle, Size},
};
use std::process::Command;

mod compositor;
mod gpu;
mod scaling;
mod xwayland;
mod steam;
mod gui;
mod ai;
mod vkbasalt;
mod mangohud;
mod gamemode;

use compositor::GameFrameCompositor;
use gui::GameFrameGui;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Inicjalizacja Wayland
    let mut display = Display::new()?;
    let mut compositor = GameFrameCompositor::new(&mut display);

    // Backend Winit dla Wayland
    let (mut winit_backend, mut winit_input) = WinitBackend::new()?;
    let mut renderer = winit_backend.renderer();

    // Backend XWayland
    let x11_backend = X11Backend::new()?;
    let x11_display = x11_backend.display();

    // Inicjalizacja GUI (opcjonalne)
    let mut gui = GameFrameGui::new();

    // Inicjalizacja vkBasalt, MangoHud, GameMode
    vkbasalt::init_vkbasalt()?;
    mangohud::init_mangohud()?;
    gamemode::start_gamemode()?;

    // Główna pętla zdarzeń
    loop {
        // Przetwarzanie zdarzeń Wayland
        display.dispatch_clients(&mut compositor)?;

        // Przetwarzanie zdarzeń Winit
        winit_input.dispatch_new_events(|event| match event {
            WinitEvent::Resized { size, .. } => {
                println!("Okno zmienione na: {:?}", size);
                compositor.resize(size);
            }
            WinitEvent::CloseRequested => {
                println!("Zamykanie aplikacji");
                gamemode::stop_gamemode()?;
                break;
            }
            _ => {}
        })?;

        // Przetwarzanie zdarzeń X11
        x11_backend.dispatch(&mut compositor)?;

        // Renderowanie z vkBasalt
        renderer.render(|renderer, frame| {
            vkbasalt::apply_post_processing(renderer, frame)?;
            Ok(())
        })?;

        // Monitorowanie wydajności z MangoHud
        mangohud::update_hud()?;

        // Optymalizacja AI
        ai::optimize_game(&compositor)?;

        // Renderowanie GUI
        gui.render(&mut renderer)?;
    }

    Ok(())
}
