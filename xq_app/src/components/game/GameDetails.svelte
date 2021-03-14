<script lang="ts">
  import type { GameInfo } from '@xq/core/analysis';

  // Props
  export let gameInfo: GameInfo;

  // Initialization
  const {
    redPlayer,
    blackPlayer,
    result,
    openingCode,
    openingName,
    event,
  } = gameInfo;

  const details: { className: string; key: string; value: string }[] = [
    {
      className: 'players',
      key: 'Result',
      value: `${formatResult(result)} — ${redPlayer} — ${blackPlayer}`,
    },
    {
      className: 'opening',
      key: 'Opening',
      value: `${openingCode}: ${openingName}`,
    },
  ];

  // Utils
  function formatResult(result: string) {
    return {
      'Red Victory': '1-0',
      Draw: '½-½',
      'Black Victory': '0-1',
    }[result];
  }
</script>

<div class="game-details">
  {#each details as { className, key, value }}
    <p class={className}>
      <span class="detail-key">{key}:</span>
      <span>{value}</span>
    </p>
  {/each}
</div>

<style lang="scss">
  .detail-key {
    font-weight: bold;
  }
</style>
