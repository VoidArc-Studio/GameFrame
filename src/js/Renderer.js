const { ipcRenderer } = require('electron');

document.getElementById('config-form').addEventListener('submit', (event) => {
    event.preventDefault();

    // Validate inputs
    const maxFps = document.getElementById('max_fps').value;
    if (maxFps < 30 || maxFps > 240) {
        alert('Max FPS must be between 30 and 240');
        return;
    }
    const refreshRate = document.getElementById('refresh_rate').value;
    if (refreshRate < 30 || refreshRate > 240) {
        alert('Refresh Rate must be between 30 and 240 Hz');
        return;
    }
    const openglVersion = document.getElementById('opengl_version').value;
    if (!/^\d+\.\d+$/.test(openglVersion)) {
        alert('OpenGL Version must be in format X.Y (e.g., 2.1)');
        return;
    }
    const vulkanVersion = document.getElementById('vulkan_version').value;
    if (!/^\d+\.\d+$/.test(vulkanVersion)) {
        alert('Vulkan Version must be in format X.Y (e.g., 1.3)');
        return;
    }

    const config = `
[General]
environment=${document.getElementById('environment').value}
resolution=${document.getElementById('resolution').value}
fullscreen=${document.getElementById('fullscreen').checked}
refresh_rate=${refreshRate}
scaling_mode=${document.getElementById('scaling_mode').value}
hdr=${document.getElementById('hdr').checked}
display_backend=${document.getElementById('display_backend').value}

[Rendering]
backend=${document.getElementById('backend').value}
vsync=${document.getElementById('vsync').checked}
max_fps=${maxFps}
filter=${document.getElementById('filter').value}

[GPU]
vendor=${document.getElementById('vendor').value}
opengl_version=${openglVersion}
vulkan_version=${vulkanVersion}
    `;

    require('fs').writeFileSync('../config/gameframe.conf', config);
    alert('Configuration saved!');
});

// Handle launch button
document.getElementById('launch-gameframe').addEventListener('click', () => {
    const profile = document.getElementById('profile').value;
    ipcRenderer.send('launch-gameframe', profile);
});

// Display launch result
ipcRenderer.on('launch-result', (event, message) => {
    alert(message);
});
