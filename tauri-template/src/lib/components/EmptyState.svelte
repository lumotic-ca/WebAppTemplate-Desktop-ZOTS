<script lang="ts">
  interface Props {
    icon?: string;
    title: string;
    message: string;
    actionLabel?: string;
    onAction?: () => void;
  }

  let {
    icon = '◎',
    title,
    message,
    actionLabel,
    onAction,
  }: Props = $props();
</script>

<div class="empty-state">
  <div class="icon" aria-hidden="true">{icon}</div>
  <h2>{title}</h2>
  <p>{message}</p>
  {#if actionLabel && onAction}
    <button class="primary-button" type="button" onclick={onAction}>{actionLabel}</button>
  {/if}
</div>

<style>
  .empty-state {
    display: grid;
    gap: 12px;
    justify-items: center;
    text-align: center;
    padding: 48px 24px;
    max-width: 420px;
    margin: 0 auto;
  }

  .icon {
    font-size: 3rem;
    color: var(--primary);
  }

  h2 {
    margin: 0;
    font-size: 1.5rem;
  }

  p {
    margin: 0;
    color: var(--text-muted);
    line-height: 1.5;
  }
</style>
