use nix::sched::{unshare, CloneFlags};
use anyhow::Result;

pub fn run_in_namespace<F, T>(f: F) -> Result<T>
where
    F: FnOnce() -> Result<T>,
{
    if let Ok(_) = unshare(CloneFlags::CLONE_NEWNS | CloneFlags::CLONE_NEWPID | CloneFlags::CLONE_NEWNET | CloneFlags::CLONE_NEWUSER) {
        log::info!("Running in isolated namespace");
        f()
    } else {
        log::warn!("unshare not supported, running without isolation");
        f()
    }
}
