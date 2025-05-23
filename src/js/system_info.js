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
            const hdrSupport = gpuInfo.vulkan_version !== 'Not supported' ? 'Supported' : 'Not supported';
            gpuElement.innerHTML = `
                <strong>GPU:</strong> ${gpuInfo.model} (${gpuInfo.vendor.toUpperCase()})<br>
                <strong>Driver:</strong> ${gpuInfo.driver_version}<br>
                <strong>Vulkan:</strong> ${gpuInfo.vulkan_version}<br>
                <strong>OpenGL:</strong> ${gpuInfo.opengl_version}<br>
                <strong>HDR:</strong> ${hdrSupport}
            `;
        } catch (e) {
            gpuElement.textContent = `GPU: Error parsing GPU info (${stdout.trim()})`;
            alert(`Failed to parse GPU info: ${e.message}`);
        }
    });

    // Detect resolutions and refresh rates
    exec('bash ../scripts/detect_resolutions.sh', (error, stdout, stderr) => {
        const resolutionSelect = document.getElementById('resolution');
        const refreshRateSelect = document.getElementById('refresh_rate');
        const resolutionsElement = document.getElementById('available-resolutions');
        const refreshRatesElement = document.getElementById('available-refresh-rates');
        if (error) {
            resolutionsElement.textContent = `Resolutions: Error detecting (${stderr})`;
            refreshRatesElement.textContent = `Refresh Rates: Error detecting (${stderr})`;
            alert(`Failed to detect resolutions: ${stderr}`);
            const defaultResolutions = ['1920x1080', '1280x720', '2560x1440', '3840x2160'];
            const defaultRefreshRates = ['60', '75', '120', '144'];
            resolutionSelect.innerHTML = '';
            defaultResolutions.forEach(res => {
                const option = document.createElement('option');
                option.value = res;
                option.textContent = res;
                resolutionSelect.appendChild(option);
            });
            refreshRateSelect.innerHTML = '';
            defaultRefreshRates.forEach(rate => {
                const option = document.createElement('option');
                option.value = rate;
                option.textContent = `${rate} Hz`;
                refreshRateSelect.appendChild(option);
            });
            resolutionsElement.textContent = `Resolutions: ${defaultResolutions.join(', ')} (Fallback)`;
            refreshRatesElement.textContent = `Refresh Rates: ${defaultRefreshRates.join(', ')} Hz (Fallback)`;
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
            resolutionsElement.textContent = `Resolutions: ${resolutionData.resolutions.join(', ')}`;
            // Simplified refresh rate detection (could parse xrandr for specific rates)
            const refreshRates = resolutionData.refresh_rates || ['60', '75', '120', '144'];
            refreshRateSelect.innerHTML = '';
            refreshRates.forEach(rate => {
                const option = document.createElement('option');
                option.value = rate;
                option.textContent = `${rate} Hz`;
                refreshRateSelect.appendChild(option);
            });
            refreshRatesElement.textContent = `Refresh Rates: ${refreshRates.join(', ')} Hz`;
        } catch (e) {
            resolutionsElement.textContent = `Resolutions: Error parsing (${e.message})`;
            refreshRatesElement.textContent = `Refresh Rates: Error parsing (${e.message})`;
            alert(`Failed to parse resolutions: ${e.message}`);
        }
    });

    // Detect CPU and memory
    const cpuInfo = os.cpus()[0].model || 'Unknown CPU';
    const totalMemory = (os.totalmem() / (1024 ** 3)).toFixed(2);
    const freeMemory = (os.freemem() / (1024 ** 3)).toFixed(2);
    document.getElementById('cpu-info').innerHTML = `
        <strong>CPU:</strong> ${cpuInfo}<br>
        <strong>Total Memory:</strong> ${totalMemory} GB<br>
        <strong>Free Memory:</strong> ${freeMemory} GB
    `;

    // Detect display backend
    exec('echo $XDG_SESSION_TYPE', (error, stdout) => {
        const displayBackend = stdout.trim() || 'Unknown';
        document.getElementById('display_backend').value = displayBackend;
        document.getElementById('display-backend').textContent = `Display Backend: ${displayBackend}`;
    });
}

// Run on startup
document.addEventListener('DOMContentLoaded', updateSystemInfo);

// Refresh system info
document.getElementById('refresh-system-info')?.addEventListener('click', updateSystemInfo);
