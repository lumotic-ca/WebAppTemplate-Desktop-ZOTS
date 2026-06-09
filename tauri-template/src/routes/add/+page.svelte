<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { addConnection, listConnections, updateConnection } from '$lib/api';
  import { displayHost, validateUrl } from '$lib/url-validator';
  import type { SavedConnection } from '$lib/types';

  let displayName = $state('');
  let url = $state('');
  let saving = $state(false);
  let error = $state<string | null>(null);
  let editing = $state<SavedConnection | null>(null);

  onMount(async () => {
    const id = $page.url.searchParams.get('id');
    if (!id) {
      return;
    }

    const connections = await listConnections();
    const existing = connections.find((item) => item.id === id);
    if (existing) {
      editing = existing;
      displayName = existing.display_name;
      url = existing.url;
    }
  });

  async function handleSave() {
    const validation = validateUrl(url);
    if (!validation.isValid) {
      error = validation.error ?? 'Invalid URL';
      return;
    }

    saving = true;
    error = null;

    try {
      if (editing) {
        await updateConnection({
          ...editing,
          display_name: displayName.trim() || displayHost(validation.normalizedUrl!),
          url: validation.normalizedUrl!,
        });
      } else {
        await addConnection(displayName, url);
      }
      await goto('/hub');
    } catch (err) {
      error = err instanceof Error ? err.message : String(err);
    } finally {
      saving = false;
    }
  }
</script>

<div class="container form-page">
  <h1>{editing ? 'Edit server' : 'Add server'}</h1>
  <p class="lead">
    {editing
      ? 'Update this saved server.'
      : 'Enter the web app URL you want to wrap.'}
  </p>

  {#if error}
    <div class="banner error" role="alert">{error}</div>
  {/if}

  <form
    class="card form"
    onsubmit={(event) => {
      event.preventDefault();
      handleSave();
    }}
  >
    <div class="field">
      <label for="display-name">Display name</label>
      <input
        id="display-name"
        name="display-name"
        type="text"
        placeholder="My App Server"
        bind:value={displayName}
      />
    </div>

    <div class="field">
      <label for="server-url">Server URL</label>
      <input
        id="server-url"
        name="server-url"
        type="url"
        placeholder="https://app.example.com"
        bind:value={url}
        required
      />
      <small>http and https URLs are supported.</small>
    </div>

    <button class="primary-button" type="submit" disabled={saving}>
      {saving ? 'Saving…' : editing ? 'Save changes' : 'Save server'}
    </button>
  </form>
</div>

<style>
  .form-page {
    max-width: 560px;
  }

  .lead {
    color: var(--text-muted);
    margin-top: 0;
  }

  .form {
    padding: 24px;
    display: grid;
    gap: 8px;
  }

  small {
    color: var(--text-muted);
  }
</style>
