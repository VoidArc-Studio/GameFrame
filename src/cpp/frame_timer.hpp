#ifndef FRAME_TIMER_HPP
#define FRAME_TIMER_HPP

#include <cstdint>

extern "C" {
    void start_frame_timer(uint32_t max_fps, uint32_t refresh_rate);
    void stop_frame_timer();
    uint64_t get_frame_count();
    double get_average_frame_time();
}

#endif
