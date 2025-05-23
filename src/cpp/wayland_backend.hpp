#ifndef WAYLAND_BACKEND_HPP
#define WAYLAND_BACKEND_HPP

#include "compositor.hpp"
#include <wlroots.h>

class WaylandBackend {
public:
    explicit WaylandBackend(const Config& config);
    ~WaylandBackend();
    void render();

private:
    Config config_;
    wlr_backend* backend_;
    wlr_compositor* compositor_;
    wlr_output* output_;
};

#endif
