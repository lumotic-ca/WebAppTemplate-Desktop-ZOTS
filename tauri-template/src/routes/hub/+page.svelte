<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import ConnectionCard from '$lib/components/ConnectionCard.svelte';
  import EmptyState from '$lib/components/EmptyState.svelte';
  import { connect, deleteConnection, listConnections } from '$lib/api';
  import type { SavedConnection } from '$lib/types';

  let connections = $state<SavedConnection[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let connectingId = $state<string | null>(null);

  async function refresh() {
    loading = true;
    error = null;
    try {
      connections = await listConnections();
    } catch (err) {
      error = err instanceof Error ? err.message : String(err);
    } finally {
      loading = false;
    }
  }

  async function handleConnect(id: string) {
    connectingId = id;
    error = null;
    try {
      const session = await connect(id);
      await goto(`/session/${session.connection.id}`);
    } catch (err) {
      error = err instanceof Error ? err.message : String(err);
    } finally {
      connectingId = null;
    }
  }

  async function handleDelete(connection: SavedConnection) {
    if (!confirm(`Remove "${connection.display_name}" from saved servers?`)) {
      return;
    }
    await deleteConnection(connection.id);
    await refresh();
  }

  onMount(refresh);
</script>

<div class="container hub">
  {#if error}
    <div class="banner error" role="alert">{error}</div>
  {/if}

  {#if loading}
    <div class="loading">Loading servers…</div>
  {:else if connections.length === 0}
    <EmptyState
      title="No servers yet"
      message="Add the web app URL you want to connect to. Your choice will be remembered next time."
      actionLabel="Add server"
      onAction={() => goto('/add')}
    />
  {:else}
    <div class="toolbar">
      <h1>Saved servers</h1>
      <button class="primary-button" type="button" onclick={() => goto('/add')}>
        Add server
      </button>
    </div>

    <div class="list">
      {#each connections as connection, index (connection.id)}
        <ConnectionCard
          {connection}
          isLastUsed={index === 0}
          isConnecting={connectingId === connection.id}
          onConnect={() => handleConnect(connection.id)}
          onEdit={() => goto(`/add?id=${connection.id}`)}
          onDelete={() => handleDelete(connection)}
        />
      {/each}
    </div>
  {/if}
</div>

<style>
  .hub {
    padding-bottom: 48px;
  }

  .toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 16px;
  }

  .toolbar h1 {
    margin: 0;
    font-size: 1.5rem;
  }

  .list {
    display: grid;
    gap: 12px;
  }

  .loading {
    text-align: center;
    color: var(--text-muted);
    padding: 48px 0;
  }
</style>
