<script lang="ts">
  export let moves: string;
</script>

<div class="panel engine-analysis-panel">
  <div class="panel-heading">Engine Analysis</div>
  <div class="panel-tabs">
    <a>Evaluation</a>
    <a>Engine Settings</a>
    <a>Board Setup</a>
  </div>
  <div class="content-container">
    {moves ?? 'Waiting for engine...'}
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
