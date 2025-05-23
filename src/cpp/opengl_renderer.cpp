#include "opengl_renderer.hpp"
#include <stdexcept>
#include <iostream>

OpenGLRenderer::OpenGLRenderer(const Config& config) : config_(config) {
    if (!glfwInit()) {
        throw std::runtime_error("Failed to initialize GLFW");
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, config.opengl_version[0] - '0');
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, config.opengl_version[2] - '0');
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    auto [width, height] = parse_resolution(config.resolution);
    window_ = glfwCreateWindow(width, height, "GameFrame", nullptr, nullptr);
    if (!window_) {
        glfwTerminate();
        throw std::runtime_error("Failed to create GLFW window");
    }

    glfwMakeContextCurrent(window_);
    glfwSwapInterval(config.vsync ? 1 : 0);

    std::cout << "OpenGL initialized (Scaling: " << config_.scaling_mode
              << ", VSync: " << (config_.vsync ? "Enabled" : "Disabled") << ")\n";
}

OpenGLRenderer::~OpenGLRenderer() {
    glfwDestroyWindow(window_);
    glfwTerminate();
}

void OpenGLRenderer::render() {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glfwSwapBuffers(window_);
    glfwPollEvents();
    std::cout << "OpenGL render (Resolution: " << config_.resolution
              << ", Refresh: " << config_.refresh_rate << " Hz, Filter: "
              << config_.filter << ")\n";
}

std::pair<int, int> parse_resolution(const std::string& resolution) {
    size_t x_pos = resolution.find('x');
    int width = std::stoi(resolution.substr(0, x_pos));
    int height = std::stoi(resolution.substr(x_pos + 1));
    return {width, height};
}
