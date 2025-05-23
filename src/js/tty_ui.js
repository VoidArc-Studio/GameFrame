const inquirer = require('inquirer');
const configManager = require('./config_manager');
const systemInfo = require('./system_info');

async function main() {
    const gpuInfo = await systemInfo.getGpuInfo();
    const resolutionInfo = await systemInfo.getResolutionInfo();

    const questions = [
        {
            type: 'list',
            name: 'environment',
            message: 'Select environment:',
            choices: ['steam-gamepadui', 'gnome', 'kde', 'heroic', 'lutris']
        },
        {
            type: 'list',
            name: 'backend',
            message: 'Select rendering backend:',
            choices: ['vulkan', 'opengl'],
            default: gpuInfo.vendor === 'intel' || gpuInfo.vulkan_version < '1.2' ? 'opengl' : 'vulkan'
        },
        {
            type: 'list',
            name: 'resolution',
            message: 'Select resolution:',
            choices: resolutionInfo.resolutions,
            default: '1920x1080'
        },
        {
            type: 'list',
            name: 'refresh_rate',
            message: 'Select refresh rate:',
            choices: resolutionInfo.refresh_rates.map(rate => `${rate} Hz`),
            default: '60 Hz'
        },
        {
            type: 'list',
            name: 'scaling_mode',
            message: 'Select scaling mode:',
            choices: ['bilinear', 'fsr'],
            default: 'bilinear'
        },
        {
            type: 'confirm',
            name: 'hdr',
            message: 'Enable HDR?',
            default: false
        },
        {
            type: 'confirm',
            name: 'vsync',
            message: 'Enable VSync?',
            default: true
        },
        {
            type: 'input',
            name: 'max_fps',
            message: 'Max FPS:',
            default: '144',
            validate: input => !isNaN(input) && input > 0
        }
    ];

    const answers = await inquirer.prompt(questions);

    const config = {
        environment: answers.environment,
        resolution: answers.resolution,
        fullscreen: true,
        refresh_rate: parseInt(answers.refresh_rate),
        scaling_mode: answers.scaling_mode,
        hdr: answers.hdr,
        display_backend: 'wayland',
        rendering: {
            backend: answers.backend,
            vsync: answers.vsync,
            max_fps: parseInt(answers.max_fps),
            filter: answers.scaling_mode
        },
        gpu: {
            vendor: gpuInfo.vendor,
            opengl_version: gpuInfo.opengl_version,
            vulkan_version: gpuInfo.vulkan_version
        }
    };

    await configManager.saveConfig(config);
    console.log('Configuration saved to config/gameframe.conf');

    const launch = await inquirer.prompt({
        type: 'confirm',
        name: 'launch',
        message: 'Launch GameFrame now?',
        default: true
    });

    if (launch.launch) {
        await configManager.launch();
        console.log('GameFrame launched!');
    }
}

main().catch(err => console.error('Error:', err));
