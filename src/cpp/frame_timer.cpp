#include "frame_timer.hpp"
#include <chrono>
#include <thread>
#include <atomic>
#include <vector>

static std::atomic<bool> running{false};
static std::atomic<uint64_t> frame_count{0};
static std::vector<double> frame_times;
static constexpr size_t MAX_FRAME_SAMPLES = 100;

extern "C" {
    void start_frame_timer(uint32_t max_fps, uint32_t refresh_rate) {
        if (running) return;
        running = true;

        auto target_frame_time = std::chrono::microseconds(1000000 / std::max(max_fps, refresh_rate));
        frame_times.reserve(MAX_FRAME_SAMPLES);

        while (running) {
            auto start = std::chrono::high_resolution_clock::now();

            // Simulate rendering work
            std::this_thread::yield();

            auto end = std::chrono::high_resolution_clock::now();
            auto elapsed = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
            if (elapsed < target_frame_time) {
                std::this_thread::sleep_for(target_frame_time - elapsed);
            }

            frame_count++;
            auto frame_time_ms = elapsed.count() / 1000.0;
            if (frame_times.size() >= MAX_FRAME_SAMPLES) {
                frame_times.erase(frame_times.begin());
            }
            frame_times.push_back(frame_time_ms);
        }
    }

    void stop_frame_timer() {
        running = false;
    }

    uint64_t get_frame_count() {
        return frame_count.load();
    }

    double get_average_frame_time() {
        if (frame_times.empty()) return 0.0;
        double sum = 0.0;
        for (double t : frame_times) {
            sum += t;
        }
        return sum / frame_times.size();
    }
}
