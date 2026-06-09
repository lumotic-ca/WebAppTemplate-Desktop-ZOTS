<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    title: string;
    subtitle?: string;
    children: Snippet;
  }

  let { title, subtitle, children }: Props = $props();
</script>

<section class="settings-section">
  <div class="heading">
    <h2>{title}</h2>
    {#if subtitle}
      <p>{subtitle}</p>
    {/if}
  </div>
  <div class="card content">
    {@render children()}
  </div>
</section>

<style>
  .settings-section {
    display: grid;
    gap: 12px;
    margin-bottom: 24px;
  }

  .heading h2 {
    margin: 0;
    font-size: 1rem;
  }

  .heading p {
    margin: 4px 0 0;
    color: var(--text-muted);
    font-size: 0.875rem;
  }

  .content {
    overflow: hidden;
  }
</style>
