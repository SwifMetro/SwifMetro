const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    restartServer: () => ipcRenderer.invoke('restart-server')
});
