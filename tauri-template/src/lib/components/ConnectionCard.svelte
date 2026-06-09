<script lang="ts">
  import { displayHost } from '$lib/url-validator';
  import type { SavedConnection } from '$lib/types';

  interface Props {
    connection: SavedConnection;
    isLastUsed?: boolean;
    isConnecting?: boolean;
    onConnect: () => void;
    onEdit?: () => void;
    onDelete?: () => void;
  }

  let {
    connection,
    isLastUsed = false,
    isConnecting = false,
    onConnect,
    onEdit,
    onDelete,
  }: Props = $props();
</script>

<article class="card connection-card">
  <div class="avatar" aria-hidden="true">
    {connection.display_name.charAt(0).toUpperCase()}
  </div>
  <div class="details">
    <div class="title-row">
      <h3>{connection.display_name}</h3>
      {#if isLastUsed}
        <span class="chip">Last used</span>
      {/if}
    </div>
    <p>{displayHost(connection.url)}</p>
  </div>
  <div class="actions">
    {#if onEdit}
      <button class="text-button" type="button" onclick={onEdit}>Edit</button>
    {/if}
    {#if onDelete}
      <button class="text-button" type="button" onclick={onDelete}>Delete</button>
    {/if}
    <button
      class="primary-button"
      type="button"
      disabled={isConnecting}
      onclick={onConnect}
    >
      {isConnecting ? 'Connecting…' : 'Connect'}
    </button>
  </div>
</article>

<style>
  .connection-card {
    display: grid;
    grid-template-columns: auto 1fr auto;
    gap: 16px;
    align-items: center;
    padding: 16px;
  }

  .avatar {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    background: color-mix(in srgb, var(--primary) 18%, transparent);
    color: var(--primary);
    font-weight: 700;
  }

  .details h3 {
    margin: 0;
    font-size: 1rem;
  }

  .details p {
    margin: 4px 0 0;
    color: var(--text-muted);
    font-size: 0.875rem;
  }

  .title-row {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
  }

  .actions {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
    justify-content: flex-end;
  }

  @media (max-width: 720px) {
    .connection-card {
      grid-template-columns: 1fr;
    }

    .actions {
      justify-content: stretch;
    }

    .actions .primary-button {
      width: 100%;
    }
  }
</style>
