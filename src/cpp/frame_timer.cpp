#include "frame_timer.hpp"
#include <chrono>
#include <thread>

extern "C" {
    void start_frame_timer(unsigned int max_fps) {
        auto frame_time = std::chrono::microseconds(1000000 / max_fps);
        while (true) {
            auto start = std::chrono::high_resolution_clock::now();
            std::this_thread::sleep_for(frame_time);
            auto end = std::chrono::high_resolution_clock::now();
            auto elapsed = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
            if (elapsed < frame_time) {
                std::this_thread::sleep_for(frame_time - elapsed);
            }
        }
    }
}
