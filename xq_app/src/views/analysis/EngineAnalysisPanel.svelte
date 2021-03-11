<script lang="ts">
  import type { EngineMetadata, EngineMove } from './types';

  export let currentTurnIndex: number;
  export let metadata: EngineMetadata[];
  export let lines: EngineMove[][];

  $: moveIndex = Math.floor(currentTurnIndex / 2);

  function formatCPScore(scorecp: number) {
    // TODO: Eventually keep track of side-to-move in boardState properly
    let v = scorecp / 100;
    if (currentTurnIndex % 2 != 0) {
      v = -v;
    }
    return v > 0 ? `+${v}` : v;
  }

  function cpScoreClassName(scorecp: number) {
    let v = scorecp;
    if (currentTurnIndex % 2 != 0) {
      v = -v;
    }
    return v > 0 ? 'is-danger' : v < 0 ? 'is-black' : 'is-light';
  }
</script>

<div class="panel engine-analysis-panel">
  <div class="panel-heading">Engine Analysis</div>
  <div class="panel-tabs">
    <!-- svelte-ignore a11y-missing-attribute -->
    <a class="is-active">Evaluation</a>
    <!-- svelte-ignore a11y-missing-attribute -->
    <a>Engine Settings</a>
    <!-- svelte-ignore a11y-missing-attribute -->
    <a>Board Setup</a>
  </div>
  <div class="content-container">
    <div class="engine panel-block">
      Fairy-Stockfish 11.2 LB 64 by Fabian Fichter
    </div>
    <div class="top-metadata panel-block">
      depth={metadata?.[0].depth ?? '0'}
      knps={metadata?.[0].nps ? Math.floor(metadata[0].nps / 1000) : '0'}
    </div>
    {#if lines}
      {#each lines as line, i}
        <div class="top-results panel-block">
          <span
            class={`scorecp tag ${cpScoreClassName(metadata[i].scorecp)} mr-2`}
            >{formatCPScore(metadata[i].scorecp)}</span
          >
          <p class="line">
            {#each line as [redMove, blackMove], j}
              {moveIndex + j + 1}. {currentTurnIndex % 2 !== 0 && j === 0
                ? '...'
                : redMove}
              {blackMove ?? ''}{' '}
            {/each}
          </p>
        </div>
      {/each}
    {:else}
      <div class="panel-block">Waiting for engine...</div>
    {/if}
  </div>
</div>

<style lang="scss">
  .engine-analysis-panel {
    margin-left: 50px;

    .content-container {
      min-height: 700px;
      height: 700px;

      .scorecp {
        font-weight: bold;
      }

      /* .line {
        max-width: 400px;

        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      } */
    }
  }
</style>
