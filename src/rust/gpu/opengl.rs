use crate::compositor::RenderBackend;
use crate::config::Config;
use glutin::config::ConfigTemplateBuilder;
use glutin::context::{ContextAttributesBuilder, PossiblyCurrentContext};
use glutin::display::Display;
use glutin::prelude::*;
use glutin::surface::{Surface, WindowSurface};
use winit::dpi::PhysicalSize;
use winit::event_loop::EventLoop;
use winit::window::{Window, WindowBuilder};

pub struct OpenGLBackend {
    context: PossiblyCurrentContext,
    surface: Surface<WindowSurface>,
    window: Window,
    config: Config,
}

impl OpenGLBackend {
    pub fn new(config: &Config) -> Self {
        let event_loop = EventLoop::new().expect("Failed to create event loop");
        let window_builder = WindowBuilder::new()
            .with_title("GameFrame")
            .with_inner_size(parse_resolution(&config.resolution));

        let template = ConfigTemplateBuilder::new()
            .with_alpha_size(8)
            .with_transparency(false)
            .build();
        let display = glutin::display::Display::new(&event_loop, template, None)
            .expect("Failed to create display");

        let config_template = unsafe {
            display.find_configs(template).expect("Failed to find configs")
                .next().expect("No suitable config found")
        };

        let window = window_builder.build(&event_loop).expect("Failed to create window");
        let surface = unsafe {
            display.create_window_surface(&config_template, &window)
                .expect("Failed to create surface")
        };

        let context_attributes = ContextAttributesBuilder::new()
            .with_context_api(glutin::context::ContextApi::OpenGl(Some(
                match config.gpu.opengl_version.as_str() {
                    "2.1" => glutin::context::Version { major: 2, minor: 1 },
                    _ => glutin::context::Version { major: 4, minor: 5 },
                },
            )))
            .build(Some(&window));
        let context = unsafe {
            display.create_context(&config_template, &context_attributes)
                .expect("Failed to create context")
                .make_current(&surface)
                .expect("Failed to make context current")
        };

        if config.rendering.vsync {
            surface.set_swap_interval(&context, glutin::surface::SwapInterval::Wait(std::num::NonZeroU32::new(1).unwrap()))
                .expect("Failed to set vsync");
        } else {
            surface.set_swap_interval(&context, glutin::surface::SwapInterval::DontWait)
                .expect("Failed to disable vsync");
        }

        OpenGLBackend { context, surface, window, config: config.clone() }
    }
}

impl RenderBackend for OpenGLBackend {
    fn render(&mut self) {
        unsafe {
            gl::ClearColor(0.0, 0.0, 0.0, 1.0);
            gl::Clear(gl::COLOR_BUFFER_BIT);
        }
        self.surface.swap_buffers(&self.context).expect("Failed to swap buffers");
        println!(
            "Rendering with OpenGL (Vendor: {}, Resolution: {}, Refresh: {} Hz, Scaling: {}, Filter: {})",
            self.config.gpu.vendor, self.config.resolution, self.config.refresh_rate,
            self.config.scaling_mode, self.config.rendering.filter
        );
    }
}

impl Drop for OpenGLBackend {
    fn drop(&mut self) {}
}

fn parse_resolution(resolution: &str) -> PhysicalSize<u32> {
    let parts: Vec<&str> = resolution.split('x').collect();
    let width = parts[0].parse().unwrap_or(1920);
    let height = parts[1].parse().unwrap_or(1080);
    PhysicalSize::new(width, height)
}
