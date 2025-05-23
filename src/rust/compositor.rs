pub struct Compositor;

impl Compositor {
    pub fn new(_config: &crate::config::Config) -> Self {
        Compositor
    }

    pub fn launch(&self, _command: &str) {
        // Handled by C++
    }

    pub fn run(&mut self) {
        // Handled by C++
    }
}
