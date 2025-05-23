const fs = require('fs');

document.getElementById('config-form').addEventListener('submit', (event) => {
    event.preventDefault();
    
    const config = `
[General]
environment=${document.getElementById('environment').value}
resolution=${document.getElementById('resolution').value}
fullscreen=${document.getElementById('fullscreen').checked}

[Rendering]
backend=${document.getElementById('backend').value}
vsync=${document.getElementById('vsync').checked}
max_fps=${document.getElementById('max_fps').value}

[GPU]
vendor=${document.getElementById('vendor').value}
opengl_version=${document.getElementById('opengl_version').value}
vulkan_version=${document.getElementById('vulkan_version').value}
    `;
    
    fs.writeFileSync('../config/gameframe.conf', config);
    alert('Configuration saved!');
});
