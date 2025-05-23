const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { exec } = require('child_process');

function createWindow() {
    const win = new BrowserWindow({
        width: 1000,
        height: 700,
        webPreferences: {
            preload: path.join(__dirname, 'renderer.js'),
            nodeIntegration: true,
            contextIsolation: false
        }
    });
    win.loadFile('index.html');
}

// Handle launch request from renderer
ipcMain.on('launch-gameframe', (event) => {
    exec('bash ../scripts/launch.sh', (error, stdout, stderr) => {
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
