use smithay::{
    backend::renderer::Renderer,
    desktop::{Space, Window},
    reexports::wayland_server::Display,
    wayland::{
        compositor::CompositorState,
        output::OutputManagerState,
        shell::xdg::XdgShellState,
    },
    utils::Size,
};

pub struct GameFrameCompositor {
    space: Space<Window>,
    compositor_state: CompositorState,
    output_manager: OutputManagerState,
    xdg_shell_state: XdgShellState,
    resolution: Size<i32, smithay::utils::Physical>,
    quality: String,
}

impl GameFrameCompositor {
    pub fn new(display: &mut Display, width: i32, height: i32, quality: String) -> Self {
        let compositor_state = CompositorState::new::<Self, _>(display, None);
        let output_manager = OutputManagerState::new_with_xdg_output::<Self>(display);
        let xdg_shell_state = XdgShellState::new::<Self, _>(display, None);
        let space = Space::new();

        GameFrameCompositor {
            space,
            compositor_state,
            output_manager,
            xdg_shell_state,
            resolution: Size::from((width, height)),
            quality,
        }
    }

    pub fn resize(&mut self, size: Size<i32, smithay::utils::Physical>) {
        self.resolution = size;
        println!("Nowa rozdzielczość: {:?}", self.resolution);
    }

    pub fn quality(&self) -> &str {
        &self.quality
    }
}
