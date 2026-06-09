<script lang="ts">
  import { onMount } from 'svelte';
  import SettingsSection from '$lib/components/SettingsSection.svelte';
  import {
    clearConnections,
    getSettings,
    setAutoReconnect,
    setThemeMode,
  } from '$lib/api';
  import type { AppSettings, ThemeMode } from '$lib/types';

  let settings = $state<AppSettings | null>(null);
  let loading = $state(true);
  let message = $state<string | null>(null);

  function applyTheme(mode: ThemeMode) {
    if (mode === 'system') {
      document.documentElement.removeAttribute('data-theme');
    } else {
      document.documentElement.setAttribute('data-theme', mode);
    }
  }

  async function load() {
    loading = true;
    settings = await getSettings();
    applyTheme(settings.theme_mode);
    loading = false;
  }

  async function handleThemeChange(event: Event) {
    const value = (event.target as HTMLSelectElement).value as ThemeMode;
    settings = await setThemeMode(value);
    applyTheme(value);
  }

  async function handleAutoReconnect(event: Event) {
    const checked = (event.target as HTMLInputElement).checked;
    settings = await setAutoReconnect(checked);
  }

  async function handleClearConnections() {
    if (
      !confirm(
        'This removes all saved connections. You will need to add a server again.',
      )
    ) {
      return;
    }
    await clearConnections();
    message = 'Saved servers cleared.';
  }

  onMount(load);
</script>

<div class="container settings-page">
  <h1>Settings</h1>

  {#if loading || !settings}
    <p>Loading settings…</p>
  {:else}
    {#if message}
      <div class="banner" role="status">{message}</div>
    {/if}

    <SettingsSection title="Appearance">
      <label class="row" for="theme-mode">
        <span>
          <strong>Theme</strong>
          <small>Choose light, dark, or follow the system.</small>
        </span>
        <select id="theme-mode" value={settings.theme_mode} onchange={handleThemeChange}>
          <option value="system">System</option>
          <option value="light">Light</option>
          <option value="dark">Dark</option>
        </select>
      </label>
    </SettingsSection>

    <SettingsSection
      title="Connection behavior"
      subtitle="Control how the app reconnects on launch."
    >
      <label class="row checkbox-row">
        <span>
          <strong>Reconnect on launch</strong>
          <small>Automatically open the last used server when the app starts.</small>
        </span>
        <input
          type="checkbox"
          checked={settings.auto_reconnect_on_launch}
          onchange={handleAutoReconnect}
        />
      </label>
    </SettingsSection>

    <SettingsSection title="Data">
      <button class="danger-button" type="button" onclick={handleClearConnections}>
        Clear saved servers
      </button>
    </SettingsSection>

    <SettingsSection
      title="App-specific settings"
      subtitle="Forks can add custom settings widgets below this section."
    >
      <p class="placeholder">No app-specific settings yet. See docs/FORKING.md to extend this section.</p>
    </SettingsSection>
  {/if}
</div>

<style>
  .settings-page {
    max-width: 720px;
    padding-bottom: 48px;
  }

  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    padding: 16px;
    border-bottom: 1px solid var(--border);
  }

  .row:last-child {
    border-bottom: none;
  }

  .row small {
    display: block;
    color: var(--text-muted);
    margin-top: 4px;
  }

  .checkbox-row input {
    width: 18px;
    height: 18px;
  }

  .danger-button {
    width: 100%;
    min-height: 48px;
    border: none;
    background: transparent;
    color: var(--danger);
    cursor: pointer;
    text-align: left;
    padding: 16px;
    font-weight: 600;
  }

  .placeholder {
    margin: 0;
    padding: 16px;
    color: var(--text-muted);
  }
</style>
