import { invoke } from '@tauri-apps/api/core';

const settingsForm = document.getElementById('settings-form') as HTMLFormElement;
const disconnectForm = document.getElementById('disconnect-form') as HTMLFormElement;
const serverInput = document.getElementById('server-url') as HTMLInputElement;
const settingsError = document.getElementById('settings-error')!;
const saveBtn = document.getElementById('save-btn') as HTMLButtonElement;
const backBtn = document.getElementById('back-btn') as HTMLButtonElement;
const disconnectBtn = document.getElementById('disconnect-btn') as HTMLButtonElement;

function setError(message: string | null) {
  if (!message) {
    settingsError.hidden = true;
    settingsError.textContent = '';
    return;
  }
  settingsError.hidden = false;
  settingsError.textContent = message;
}

async function loadSavedUrl() {
  try {
    const savedUrl = await invoke<string | null>('get_saved_url');
    if (savedUrl) {
      serverInput.value = savedUrl;
    }
  } catch {
    // ignore
  }
}

settingsForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(null);
  saveBtn.disabled = true;

  try {
    await invoke('save_server_url', { url: serverInput.value });
  } catch (error) {
    setError(error instanceof Error ? error.message : String(error));
    saveBtn.disabled = false;
  }
});

backBtn.addEventListener('click', () => {
  void invoke('return_to_erp').catch((error) => {
    setError(error instanceof Error ? error.message : String(error));
  });
});

disconnectForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(null);
  disconnectBtn.disabled = true;

  try {
    await invoke('reset_server');
  } catch (error) {
    setError(error instanceof Error ? error.message : String(error));
    disconnectBtn.disabled = false;
  }
});

void loadSavedUrl();
