use clap::Parser;
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
mod tty;

use compositor::GameFrameCompositor;
use gui::GameFrameGui;
use tty::init_tty_session;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Rozdzielczość w formacie WxH, np. 1920x1080
    resolution: String,
    /// Jakość skalowania: 4k, high, low
    quality: String,
    /// Dodatkowe opcje: ++ (wszystkie), +vk (vkBasalt), +hud (MangoHud), +gm (GameMode)
    #[arg(default_value = "")]
    options: String,
    /// Aplikacja do uruchomienia, np. "steam -gamepadui"
    #[arg(default_value = "steam -gamepadui")]
    application: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Inicjalizacja logowania
    env_logger::init();

    // Parsowanie argumentów
    let args = Args::parse();
    let (width, height) = parse_resolution(&args.resolution)?;
    let quality = parse_quality(&args.quality);
    let (use_vkbasalt, use_mangohud, use_gamemode) = parse_options(&args.options);

    // Inicjalizacja sesji TTY
    init_tty_session()?;

    // Inicjalizacja Wayland
    let mut display = Display::new()?;
    let mut compositor = GameFrameCompositor::new(&mut display, width, height, quality);

    // Backend Winit dla Wayland
    let (mut winit_backend, mut winit_input) = WinitBackend::new()?;
    let mut renderer = winit_backend.renderer();

    // Backend XWayland
    let x11_backend = X11Backend::new()?;
    let x11_display = x11_backend.display();

    // Inicjalizacja integracji
    if use_vkbasalt {
        vkbasalt::init_vkbasalt()?;
    }
    if use_mangohud {
        mangohud::init_mangohud()?;
    }
    if use_gamemode {
        gamemode::start_gamemode()?;
    }

    // Uruchomienie aplikacji
    steam::launch_application(&args.application)?;

    // Inicjalizacja GUI
    let mut gui = GameFrameGui::new(quality);

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
                if use_gamemode {
                    gamemode::stop_gamemode()?;
                }
                break;
            }
            _ => {}
        })?;

        // Przetwarzanie zdarzeń X11
        x11_backend.dispatch(&mut compositor)?;

        // Renderowanie z vkBasalt
        renderer.render(|renderer, frame| {
            if use_vkbasalt {
                vkbasalt::apply_post_processing(renderer, frame)?;
            }
            Ok(())
        })?;

        // Aktualizacja MangoHud
        if use_mangohud {
            mangohud::update_hud()?;
        }

        // Optymalizacja AI
        ai::optimize_game(&compositor)?;

        // Renderowanie GUI
        gui.render(&mut renderer)?;
    }

    Ok(())
}

fn parse_resolution(res: &str) -> Result<(i32, i32), Box<dyn std::error::Error>> {
    let parts: Vec<&str> = res.split('x').collect();
    if parts.len() != 2 {
        return Err("Nieprawidłowy format rozdzielczości (oczekiwano WxH)".into());
    }
    let width: i32 = parts[0].parse()?;
    let height: i32 = parts[1].parse()?;
    Ok((width, height))
}

fn parse_quality(quality: &str) -> String {
    match quality.to_lowercase().as_str() {
        "4k" => "FSR".to_string(),
        "high" => "Bilinear".to_string(),
        "low" => "Integer".to_string(),
        _ => "FSR".to_string(),
    }
}

fn parse_options(options: &str) -> (bool, bool, bool) {
    let options = options.to_lowercase();
    if options.contains("++") {
        (true, true, true)
    } else {
        (
            options.contains("+vk"),
            options.contains("+hud"),
            options.contains("+gm"),
        )
    }
}
