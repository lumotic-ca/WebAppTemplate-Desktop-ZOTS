<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { appConfig } from '$lib/app-config';
  import { connect, getLastUsedConnection, getSettings } from '$lib/api';

  onMount(async () => {
    const settings = await getSettings();

    if (settings.auto_reconnect_on_launch) {
      const lastUsed = await getLastUsedConnection();
      if (lastUsed) {
        try {
          const session = await connect(lastUsed.id);
          await goto(`/session/${session.connection.id}`);
          return;
        } catch {
          // Fall through to hub on connect failure.
        }
      }
    }

    await goto('/hub');
  });
</script>

<div class="bootstrap">
  <div class="spinner" aria-hidden="true"></div>
  <p>{appConfig.appName}</p>
</div>

<style>
  .bootstrap {
    min-height: 100vh;
    display: grid;
    place-items: center;
    gap: 16px;
  }

  .spinner {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: 3px solid var(--border);
    border-top-color: var(--primary);
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>
