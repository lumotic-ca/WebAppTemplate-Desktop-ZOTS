<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { listen } from '@tauri-apps/api/event';
  import { appConfig } from '$lib/app-config';
  import { getSettings } from '$lib/api';
  import '../styles/theme.css';

  let { children } = $props();
  let themeReady = $state(false);

  const showHeader = $derived(
    $page.url.pathname !== '/' && !$page.url.pathname.startsWith('/session'),
  );

  function applyTheme(mode: 'system' | 'light' | 'dark') {
    if (mode === 'system') {
      document.documentElement.removeAttribute('data-theme');
    } else {
      document.documentElement.setAttribute('data-theme', mode);
    }
  }

  onMount(() => {
    let unlisten: (() => void) | undefined;

    (async () => {
      const settings = await getSettings();
      applyTheme(settings.theme_mode);
      themeReady = true;

      unlisten = await listen<string>('session-ended', async () => {
        if ($page.url.pathname.startsWith('/session')) {
          await goto('/hub');
        }
      });
    })();

    return () => {
      unlisten?.();
    };
  });
</script>

{#if themeReady}
  <div class="app-shell">
    {#if showHeader}
      <header class="app-header">
        <div class="app-title">{appConfig.appName}</div>
        <nav class="nav">
          {#if $page.url.pathname !== '/hub'}
            <a class="text-button" href="/hub">Servers</a>
          {/if}
          {#if $page.url.pathname !== '/settings'}
            <a class="text-button" href="/settings">Settings</a>
          {/if}
        </nav>
      </header>
    {/if}
    <main>
      {@render children()}
    </main>
  </div>
{/if}

<style>
  .app-shell {
    min-height: 100vh;
  }

  .nav {
    display: flex;
    gap: 8px;
  }

  .nav a {
    display: inline-flex;
    align-items: center;
    min-height: 40px;
    padding: 0 12px;
    border-radius: var(--radius);
  }

  .nav a:hover {
    background: color-mix(in srgb, var(--primary) 10%, transparent);
  }
</style>
