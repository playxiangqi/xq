<script lang="ts">
  export let moves: string[];
</script>

<div class="panel engine-analysis-panel">
  <div class="panel-heading">Engine Analysis</div>
  <div class="panel-tabs">
    <a>Evaluation</a>
    <a>Engine Settings</a>
    <a>Board Setup</a>
  </div>
  <div class="content-container">
    {#if moves}
      {#each moves as line}
        <div class="panel-block">{line}</div>
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
    }
  }
</style>
