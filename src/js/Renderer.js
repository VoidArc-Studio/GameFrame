const { ipcRenderer } = require('electron');

document.getElementById('config-form').addEventListener('submit', (event) => {
    event.preventDefault();
    
    // Validate inputs
    const maxFps = document.getElementById('max_fps').value;
    if (maxFps < 30 || maxFps > 240) {
        alert('Max FPS must be between 30 and 240');
        return;
    }
    
    const config = `
[General]
environment=${document.getElementById('environment').value}
resolution=${document.getElementById('resolution').value}
fullscreen=${document.getElementById('fullscreen').checked}

[Rendering]
backend=${document.getElementById('backend').value}
vsync=${document.getElementById('vsync').checked}
max_fps=${maxFps}

[GPU]
vendor=${document.getElementById('vendor').value}
opengl_version=${document.getElementById('opengl_version').value}
vulkan_version=${document.getElementById('vulkan_version').value}
    `;
    
    // Save to default config file
    require('fs').writeFileSync('../config/gameframe.conf', config);
    alert('Configuration saved!');
});

// Handle launch button
document.getElementById('launch-gameframe').addEventListener('click', () => {
    ipcRenderer.send('launch-gameframe');
});

// Display launch result
ipcRenderer.on('launch-result', (event, message) => {
    alert(message);
});
