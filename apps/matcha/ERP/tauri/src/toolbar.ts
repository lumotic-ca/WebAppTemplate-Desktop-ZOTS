import { invoke } from '@tauri-apps/api/core';

document.getElementById('refresh-btn')!.addEventListener('click', () => {
  void invoke('refresh_erp').catch((error) => {
    console.error(error);
  });
});

document.getElementById('settings-btn')!.addEventListener('click', () => {
  void invoke('open_settings').catch((error) => {
    console.error(error);
  });
});
