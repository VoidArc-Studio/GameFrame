const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { exec } = require('child_process');

function createWindow() {
    const win = new BrowserWindow({
        width: 1200,
        height: 800,
        webPreferences: {
            preload: path.join(__dirname, 'renderer.js'),
            nodeIntegration: true,
            contextIsolation: false
        }
    });
    win.loadFile('index.html');
}

// Handle launch request with profile
ipcMain.on('launch-gameframe', (event, profile) => {
    const command = profile === 'default' ? 'bash ../scripts/launch.sh' : `bash ../scripts/launch.sh ${profile}`;
    exec(command, (error, stdout, stderr) => {
        if (error) {
            event.reply('launch-result', `Error launching GameFrame: ${stderr}`);
            return;
        }
        event.reply('launch-result', `GameFrame launched: ${stdout}`);
    });
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});
