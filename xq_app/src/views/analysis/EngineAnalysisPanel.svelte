<script lang="ts">
  import type { EngineMetadata } from './types';

  export let metadata: EngineMetadata[];
  export let lines: [string, string | undefined][][];

  function formatCPScore(scorecp: number) {
    const v = scorecp / 100;
    return v > 0 ? `+${v}` : v < 0 ? `-${v}` : v;
  }

  function cpScoreClassName(scorecp: number) {
    return scorecp > 0 ? 'is-danger' : scorecp < 0 ? 'is-black' : 'is-light';
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
    {#if lines}
      {#each lines as line, i}
        <div class="panel-block">
          <span
            class={`scorecp tag ${cpScoreClassName(metadata[i].scorecp)} mr-2`}
            >{formatCPScore(metadata[i].scorecp)}</span
          >
          <p class="lines">
            {#each line as [redMove, blackMove], j}
              {j + 1}. {redMove} {blackMove ?? ''}{' '}
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

    li {
      list-style-type: none;
    }
    .content-container {
      min-height: 700px;
      height: 700px;

      .scorecp {
        font-weight: bold;
      }

      .lines {
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }
  }
</style>
