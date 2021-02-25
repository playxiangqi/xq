<script lang="ts">
  import GameInfoTable from './GameInfoTable.svelte';
  import SearchForm from './SearchForm.svelte';
  import type { GameInfo } from 'utils/game';

  let gameInfos: GameInfo[] = [];
</script>

<div class="database-explorer">
  <div class="col-1" />
  <div class="main-panel panel">
    <p class="panel-heading">Database Explorer</p>
    <div class="search-form-container panel-block">
      <SearchForm bind:gameInfos />
    </div>
    <div class="search-results-container panel-block">
      <GameInfoTable {gameInfos} />
    </div>
  </div>
  <div class="col-3" />
</div>

<style lang="scss">
  .database-explorer {
    margin-top: 15px;

    display: grid;
    grid-template-columns: 1fr 6.75fr 1fr;

    .search-results-container {
      min-height: 600px;

      align-items: flex-start;
      flex-direction: row;
      flex-wrap: wrap;
    }
  }
</style>
