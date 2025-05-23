#ifndef OPENGL_RENDERER_HPP
#define OPENGL_RENDERER_HPP

#include "compositor.hpp"
#include <GL/gl.h>
#include <GLFW/glfw3.h>

class OpenGLRenderer {
public:
    explicit OpenGLRenderer(const Config& config);
    ~OpenGLRenderer();
    void render();

private:
    Config config_;
    GLFWwindow* window_;
};

#endif
