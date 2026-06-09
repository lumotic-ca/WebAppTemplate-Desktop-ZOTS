import { invoke } from '@tauri-apps/api/core';

const splash = document.getElementById('splash')!;
const setup = document.getElementById('setup')!;
const setupForm = document.getElementById('setup-form') as HTMLFormElement;
const serverInput = document.getElementById('server-url') as HTMLInputElement;
const setupError = document.getElementById('setup-error')!;
const connectBtn = document.getElementById('connect-btn') as HTMLButtonElement;
const splashMessage = document.getElementById('splash-message')!;

function showSplash(message: string) {
  splashMessage.textContent = message;
  splash.hidden = false;
  setup.hidden = true;
}

function showSetup() {
  splash.hidden = true;
  setup.hidden = false;
}

function setError(message: string | null) {
  if (!message) {
    setupError.hidden = true;
    setupError.textContent = '';
    return;
  }
  setupError.hidden = false;
  setupError.textContent = message;
}

setupForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(null);
  connectBtn.disabled = true;

  try {
    showSplash('Saving and opening ERPNext…');
    await invoke('save_server_url', { url: serverInput.value });
  } catch (error) {
    showSetup();
    setError(error instanceof Error ? error.message : String(error));
    connectBtn.disabled = false;
  }
});

async function bootstrap() {
  try {
    const savedUrl = await invoke<string | null>('get_saved_url');
    if (savedUrl) {
      showSplash('Opening ERPNext…');
      return;
    }
    showSetup();
  } catch {
    showSetup();
  }
}

void bootstrap();
