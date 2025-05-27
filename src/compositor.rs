use smithay::{
    backend::renderer::Renderer,
    desktop::{Space, Window},
    reexports::wayland_server::Display,
    wayland::compositor::CompositorState,
    wayland::output::OutputManagerState,
};

pub struct GameFrameCompositor {
    space: Space<Window>,
    compositor_state: CompositorState,
    output_manager: OutputManagerState,
    resolution: Size<i32, smithay::utils::Physical>,
}

impl GameFrameCompositor {
    pub fn new(display: &mut Display) -> Self {
        let compositor_state = CompositorState::new::<Self, _>(display, None);
        let output_manager = OutputManagerState::new_with_xdg_output::<Self>(display);
        let space = Space::new();

        GameFrameCompositor {
            space,
            compositor_state,
            output_manager,
            resolution: Size::from((1280, 720)),
        }
    }

    pub fn resize(&mut self, size: Size<i32, smithay::utils::Physical>) {
        self.resolution = size;
        // Spoofing rozdzielczości
        println!("Nowa rozdzielczość: {:?}", self.resolution);
    }
}
