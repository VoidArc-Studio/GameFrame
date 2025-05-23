#include "compositor.hpp"
#include "vulkan_renderer.hpp"
#include "opengl_renderer.hpp"
#include "wayland_backend.hpp"
#include <stdexcept>
#include <cstdlib>

extern "C" {
    void start_compositor(const Config* config);
    void stop_compositor();
    void launch_environment(const char* command);
}

Compositor::Compositor(const Config& config) : config_(config) {
    if (config_.display_backend == "wayland") {
        renderer_ = std::make_unique<WaylandBackend>(config_);
    } else if (config_.rendering_backend == "vulkan") {
        renderer_ = std::make_unique<VulkanRenderer>(config_);
    } else if (config_.rendering_backend == "opengl") {
        renderer_ = std::make_unique<OpenGLRenderer>(config_);
    } else {
        throw std::runtime_error("Unsupported backend");
    }
}

Compositor::~Compositor() {}

void Compositor::launch(const std::string& command) {
    std::system(("sh -c \"" + command + "\" &").c_str());
}

void Compositor::run() {
    start_frame_timer(config_.max_fps, config_.refresh_rate);
    while (true) {
        renderer_->render();
    }
}

extern "C" {
    static Compositor* compositor = nullptr;

    void start_compositor(const Config* config) {
        compositor = new Compositor(*config);
    }

    void stop_compositor() {
        delete compositor;
        compositor = nullptr;
        stop_frame_timer();
    }

    void launch_environment(const char* command) {
        if (compositor) {
            compositor->launch(command);
        }
    }
}
