use crate::config::Config;
use crate::gpu::{VulkanBackend, OpenGLBackend, WaylandBackend};
use std::process::Command;

pub struct Compositor {
    config: Config,
    backend: Box<dyn RenderBackend>,
}

pub trait RenderBackend {
    fn render(&mut self);
}

impl Compositor {
    pub fn new(config: &Config) -> Self {
        let backend: Box<dyn RenderBackend> = match config.display_backend.as_str() {
            "wayland" => Box::new(WaylandBackend::new(config)),
            _ => match config.rendering.backend.as_str() {
                "vulkan" => Box::new(VulkanBackend::new(config)),
                "opengl" => Box::new(OpenGLBackend::new(config)),
                _ => panic!("Unsupported backend"),
            },
        };
        Compositor { config: config.clone(), backend }
    }

    pub fn launch(&self, command: &str) {
        Command::new("sh")
            .arg("-c")
            .arg(command)
            .spawn()
            .expect("Failed to launch environment");
    }

    pub fn run(&mut self) {
        unsafe {
            crate::cpp::start_frame_timer(self.config.rendering.max_fps);
        }
        loop {
            self.backend.render();
        }
    }
}
