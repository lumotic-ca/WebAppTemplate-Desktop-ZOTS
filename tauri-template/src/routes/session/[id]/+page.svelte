<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { disconnect, getActiveSession, listConnections } from '$lib/api';
  import type { SavedConnection } from '$lib/types';

  let connection = $state<SavedConnection | null>(null);
  let loading = $state(true);
  let disconnecting = $state(false);

  onMount(async () => {
    const session = await getActiveSession();
    if (session) {
      connection = session.connection;
      loading = false;
      return;
    }

    const id = $page.params.id;
    const connections = await listConnections();
    connection = connections.find((item) => item.id === id) ?? null;
    loading = false;

    if (!connection) {
      await goto('/hub');
    }
  });

  async function handleDisconnect() {
    disconnecting = true;
    try {
      await disconnect();
      await goto('/hub');
    } finally {
      disconnecting = false;
    }
  }
</script>

<div class="container session-page">
  {#if loading}
    <p>Loading session…</p>
  {:else if connection}
    <div class="session-card card">
      <div class="icon" aria-hidden="true">↗</div>
      <h1>Connected</h1>
      <p>
        <strong>{connection.display_name}</strong> is open in a separate window.
      </p>
      <button
        class="primary-button"
        type="button"
        disabled={disconnecting}
        onclick={handleDisconnect}
      >
        {disconnecting ? 'Disconnecting…' : 'Disconnect'}
      </button>
    </div>
  {/if}
</div>

<style>
  .session-page {
    min-height: calc(100vh - 73px);
    display: grid;
    place-items: center;
  }

  .session-card {
    max-width: 480px;
    width: 100%;
    padding: 32px 24px;
    text-align: center;
    display: grid;
    gap: 12px;
    justify-items: center;
  }

  .icon {
    font-size: 3rem;
    color: var(--primary);
  }

  h1 {
    margin: 0;
  }

  p {
    margin: 0;
    color: var(--text-muted);
    line-height: 1.5;
  }
</style>
