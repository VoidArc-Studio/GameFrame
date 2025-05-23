use clap::Parser;

#[derive(Parser, Debug)]
#[clap(name = "gameframe", about = "A Gamescope-like compositor for Linux")]
pub struct Cli {
    #[clap(long, help = "Use OpenGL backend")]
    pub opengl: bool,

    #[clap(long, help = "Use Vulkan backend")]
    pub vulkan: bool,

    #[clap(help = "Resolution (e.g., 1920x1080)")]
    pub resolution: Option<String>,

    #[clap(long, help = "Environment to launch (e.g., steam, gnome)")]
    pub environment: Option<String>,
}
