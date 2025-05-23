#ifndef VULKAN_RENDERER_HPP
#define VULKAN_RENDERER_HPP

#include "compositor.hpp"
#include <vulkan/vulkan.hpp>

class VulkanRenderer {
public:
    explicit VulkanRenderer(const Config& config);
    ~VulkanRenderer();
    void render();

private:
    Config config_;
    vk::Instance instance_;
    vk::PhysicalDevice physical_device_;
    vk::Device device_;
    vk::Queue queue_;
    // Add swapchain, pipeline, etc. for full implementation
};

#endif
