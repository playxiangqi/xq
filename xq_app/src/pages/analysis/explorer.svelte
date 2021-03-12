<script lang="ts">
  import { GameInfoTable, SearchForm } from '@xq/core/analysis';
  import type { GameInfo } from '@xq/core/analysis';

  let gameInfos: GameInfo[] = [];
</script>

<div class="database-explorer">
  <div class="main-panel panel">
    <p class="panel-heading">Database Explorer</p>
    <div class="search-form-container panel-block">
      <SearchForm bind:gameInfos />
    </div>
    <div class="search-results-container panel-block">
      <GameInfoTable {gameInfos} />
    </div>
  </div>
</div>

<style lang="scss">
  .database-explorer {
    margin: 10px 50px 0px 50px;

    .search-results-container {
      min-height: 700px;

      align-items: flex-start;
      flex-direction: row;
      flex-wrap: wrap;
    }
  }
</style>
