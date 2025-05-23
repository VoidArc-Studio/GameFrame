#ifndef COMPOSITOR_HPP
#define COMPOSITOR_HPP

#include <string>
#include <memory>

struct Config {
    std::string environment;
    std::string resolution;
    bool fullscreen;
    uint32_t refresh_rate;
    std::string scaling_mode;
    bool hdr;
    std::string display_backend;
    std::string rendering_backend;
    bool vsync;
    uint32_t max_fps;
    std::string filter;
    std::string gpu_vendor;
    std::string opengl_version;
    std::string vulkan_version;
};

class Compositor {
public:
    explicit Compositor(const Config& config);
    ~Compositor();

    void launch(const std::string& command);
    void run();

private:
    Config config_;
    std::unique_ptr<class Renderer> renderer_;
};

#endif
