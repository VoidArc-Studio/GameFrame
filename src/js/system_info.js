const { exec } = require('child_process');
const os = require('os');

function updateSystemInfo() {
    // Detect GPU
    exec('bash ../scripts/detect_gpu.sh', (error, stdout, stderr) => {
        const gpuElement = document.getElementById('gpu-vendor');
        if (error) {
            gpuElement.textContent = `GPU: Error detecting (${stderr})`;
            alert(`Failed to detect GPU: ${stderr}`);
            return;
        }
        try {
            const gpuInfo = JSON.parse(stdout);
            gpuElement.innerHTML = `
                <strong>GPU:</strong> ${gpuInfo.model} (${gpuInfo.vendor.toUpperCase()})<br>
                <strong>Driver:</strong> ${gpuInfo.driver_version}<br>
                <strong>Vulkan:</strong> ${gpuInfo.vulkan_version}<br>
                <strong>OpenGL:</strong> ${gpuInfo.opengl_version}
            `;
        } catch (e) {
            gpuElement.textContent = `GPU: Error parsing GPU info (${stdout.trim()})`;
            alert(`Failed to parse GPU info: ${e.message}`);
        }
    });

    // Detect resolutions
    exec('bash ../scripts/detect_resolutions.sh', (error, stdout, stderr) => {
        const resolutionSelect = document.getElementById('resolution');
        const resolutionsElement = document.getElementById('available-resolutions');
        if (error) {
            resolutionsElement.textContent = `Available Resolutions: Error detecting (${stderr})`;
            alert(`Failed to detect resolutions: ${stderr}`);
            // Fallback to default resolutions
            const defaultResolutions = ['1920x1080', '1280x720', '2560x1440', '3840x2160'];
            resolutionSelect.innerHTML = '';
            defaultResolutions.forEach(res => {
                const option = document.createElement('option');
                option.value = res;
                option.textContent = res;
                resolutionSelect.appendChild(option);
            });
            resolutionsElement.textContent = `Available Resolutions: ${defaultResolutions.join(', ')} (Fallback)`;
            return;
        }
        try {
            const resolutionData = JSON.parse(stdout);
            resolutionSelect.innerHTML = '';
            resolutionData.resolutions.forEach(res => {
                const option = document.createElement('option');
                option.value = res;
                option.textContent = res;
                resolutionSelect.appendChild(option);
            });
            resolutionsElement.textContent = `Available Resolutions: ${resolutionData.resolutions.join(', ')}`;
        } catch (e) {
            resolutionsElement.textContent = `Available Resolutions: Error parsing (${e.message})`;
            alert(`Failed to parse resolutions: ${e.message}`);
        }
    });

    // Detect CPU and memory
    const cpuInfo = os.cpus()[0].model || 'Unknown CPU';
    const totalMemory = (os.totalmem() / (1024 ** 3)).toFixed(2); // Convert to GB
    const freeMemory = (os.freemem() / (1024 ** 3)).toFixed(2); // Convert to GB
    document.getElementById('cpu-info').innerHTML = `
        <strong>CPU:</strong> ${cpuInfo}<br>
        <strong>Total Memory:</strong> ${totalMemory} GB<br>
        <strong>Free Memory:</strong> ${freeMemory} GB
    `;

    // Detect display backend (X11 or Wayland)
    exec('echo $XDG_SESSION_TYPE', (error, stdout) => {
        const displayBackend = stdout.trim() || 'Unknown';
        document.getElementById('display-backend').textContent = `Display Backend: ${displayBackend}`;
    });
}

// Run on startup
document.addEventListener('DOMContentLoaded', updateSystemInfo);

// Refresh system info on demand
document.getElementById('refresh-system-info')?.addEventListener('click', updateSystemInfo);
