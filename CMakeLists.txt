cmake_minimum_required(VERSION 3.10)
project(GameFrame CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Vulkan REQUIRED)
find_package(OpenGL REQUIRED)
find_package(glfw3 REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(WLROOTS REQUIRED wlroots)

add_library(gameframe SHARED
    src/cpp/frame_timer.cpp
    src/cpp/compositor.cpp
    src/cpp/vulkan_renderer.cpp
    src/cpp/opengl_renderer.cpp
    src/cpp/wayland_backend.cpp
)

target_include_directories(gameframe PRIVATE
    ${Vulkan_INCLUDE_DIRS}
    ${OPENGL_INCLUDE_DIRS}
    ${WLROOTS_INCLUDE_DIRS}
)

target_link_libraries(gameframe PRIVATE
    ${Vulkan_LIBRARIES}
    ${OPENGL_LIBRARIES}
    glfw
    ${WLROOTS_LIBRARIES}
)

install(TARGETS gameframe DESTINATION lib)
