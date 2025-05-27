use nix::fcntl::{open, OFlag};
use nix::sys::stat::Mode;
use nix::unistd::{close, dup2};
use std::fs::File;
use std::io::Write;
use std::os::unix::io::AsRawFd;

pub fn init_tty_session() -> Result<(), Box<dyn std::error::Error>> {
    // Otwarcie TTY (np. /dev/tty1)
    let tty = open("/dev/tty1", OFlag::O_RDWR, Mode::empty())?;
    
    // Przełączenie na TTY
    nix::ioctl::ioctl(tty, nix::libc::TIOCSCTTY, 0)?;

    // Przekierowanie stdin, stdout, stderr na TTY
    dup2(tty, 0)?;
    dup2(tty, 1)?;
    dup2(tty, 2)?;
    close(tty)?;

    // Ustawienie zmiennych środowiskowych dla Wayland
    std::env::set_var("XDG_RUNTIME_DIR", "/run/user/1000");
    std::env::set_var("WAYLAND_DISPLAY", "wayland-0");

    // Uruchomienie sesji graficznej
    println!("Inicjalizacja sesji graficznej w TTY");
    Ok(())
}
