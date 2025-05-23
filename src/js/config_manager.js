const fs = require('fs');
const path = require('path');

// Ensure profiles directory exists
const profilesDir = path.join(__dirname, '../config/profiles');
if (!fs.existsSync(profilesDir)) {
    fs.mkdirSync(profilesDir, { recursive: true });
}

// Populate profile dropdown
function loadProfiles() {
    const profileSelect = document.getElementById('profile');
    fs.readdir(profilesDir, (err, files) => {
        if (err) {
            console.error('Error reading profiles:', err);
            return;
        }
        profileSelect.innerHTML = '<option value="default">Default</option>';
        files.forEach(file => {
            if (file.endsWith('.conf')) {
                const profileName = file.replace('.conf', '');
                const option = document.createElement('option');
                option.value = profileName;
                option.textContent = profileName;
                profileSelect.appendChild(option);
            }
        });
    });
}

// Save current configuration as a new profile
document.getElementById('save-profile').addEventListener('click', () => {
    const profileName = prompt('Enter profile name:');
    if (!profileName) return;

    const config = `
[General]
environment=${document.getElementById('environment').value}
resolution=${document.getElementById('resolution').value}
fullscreen=${document.getElementById('fullscreen').checked}
refresh_rate=${document.getElementById('refresh_rate').value}
scaling_mode=${document.getElementById('scaling_mode').value}
hdr=${document.getElementById('hdr').checked}
display_backend=${document.getElementById('display_backend').value}

[Rendering]
backend=${document.getElementById('backend').value}
vsync=${document.getElementById('vsync').checked}
max_fps=${document.getElementById('max_fps').value}
filter=${document.getElementById('filter').value}

[GPU]
vendor=${document.getElementById('vendor').value}
opengl_version=${document.getElementById('opengl_version').value}
vulkan_version=${document.getElementById('vulkan_version').value}
    `;

    fs.writeFileSync(path.join(profilesDir, `${profileName}.conf`), config);
    loadProfiles();
    alert(`Profile ${profileName} saved!`);
});

// Load selected profile into form
document.getElementById('load-profile').addEventListener('click', () => {
    const profileName = document.getElementById('profile').value;
    if (profileName === 'default') {
        alert('Select a custom profile to load');
        return;
    }

    const profilePath = path.join(profilesDir, `${profileName}.conf`);
    if (!fs.existsSync(profilePath)) {
        alert('Profile not found!');
        return;
    }

    const config = fs.readFileSync(profilePath, 'utf-8');
    const lines = config.split('\n');
    const formData = {
        environment: '', resolution: '', fullscreen: false, refresh_rate: '', scaling_mode: '',
        hdr: false, display_backend: '', backend: '', vsync: false, max_fps: '', filter: '',
        vendor: '', opengl_version: '', vulkan_version: ''
    };

    let section = '';
    lines.forEach(line => {
        if (line.startsWith('[General]')) section = 'General';
        else if (line.startsWith('[Rendering]')) section = 'Rendering';
        else if (line.startsWith('[GPU]')) section = 'GPU';
        else if (line.includes('=')) {
            const [key, value] = line.split('=').map(s => s.trim());
            if (section === 'General') {
                if (key === 'environment') formData.environment = value;
                if (key === 'resolution') formData.resolution = value;
                if (key === 'fullscreen') formData.fullscreen = value === 'true';
                if (key === 'refresh_rate') formData.refresh_rate = value;
                if (key === 'scaling_mode') formData.scaling_mode = value;
                if (key === 'hdr') formData.hdr = value === 'true';
                if (key === 'display_backend') formData.display_backend = value;
            } else if (section === 'Rendering') {
                if (key === 'backend') formData.backend = value;
                if (key === 'vsync') formData.vsync = value === 'true';
                if (key === 'max_fps') formData.max_fps = value;
                if (key === 'filter') formData.filter = value;
            } else if (section === 'GPU') {
                if (key === 'vendor') formData.vendor = value;
                if (key === 'opengl_version') formData.opengl_version = value;
                if (key === 'vulkan_version') formData.vulkan_version = value;
            }
        }
    });

    // Update form fields
    document.getElementById('environment').value = formData.environment;
    document.getElementById('resolution').value = formData.resolution;
    document.getElementById('fullscreen').checked = formData.fullscreen;
    document.getElementById('refresh_rate').value = formData.refresh_rate;
    document.getElementById('scaling_mode').value = formData.scaling_mode;
    document.getElementById('hdr').checked = formData.hdr;
    document.getElementById('display_backend').value = formData.display_backend;
    document.getElementById('backend').value = formData.backend;
    document.getElementById('vsync').checked = formData.vsync;
    document.getElementById('max_fps').value = formData.max_fps;
    document.getElementById('filter').value = formData.filter;
    document.getElementById('vendor').value = formData.vendor;
    document.getElementById('opengl_version').value = formData.opengl_version;
    document.getElementById('vulkan_version').value = formData.vulkan_version;

    alert(`Profile ${profileName} loaded!`);
});

// Load profiles on startup
document.addEventListener('DOMContentLoaded', loadProfiles);
