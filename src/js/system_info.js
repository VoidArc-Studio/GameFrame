const { exec } = require('child_process');

function updateSystemInfo() {
    // Detect GPU
    exec('bash ../scripts/detect_gpu.sh', (error, stdout, stderr) => {
        if (error) {
            document.getElementById('gpu-vendor').textContent = `GPU Vendor: Error detecting (${stderr})`;
            return;
        }
        document.getElementById('gpu-vendor').textContent = `GPU Vendor: ${stdout.trim()}`;
    });

    // Detect available resolutions (simplified, could use xrandr or similar)
    const resolutions = ['1920x1080', '1280x720', '2560x1440', '3840x2160'];
    const resolutionSelect = document.getElementById('resolution');
    resolutionSelect.innerHTML = '';
    resolutions.forEach(res => {
        const option = document.createElement('option');
        option.value = res;
        option.textContent = res;
        resolutionSelect.appendChild(option);
    });
    document.getElementById('available-resolutions').textContent = `Available Resolutions: ${resolutions.join(', ')}`;
}

// Run on startup
document.addEventListener('DOMContentLoaded', updateSystemInfo);
