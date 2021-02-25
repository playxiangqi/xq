<script lang="ts">
  import type { GameInfo } from 'utils/game';

  export let gameInfos: GameInfo[];
  export let pageSize = 20;

  let currentPage = 0;
  let numPages = 0;
  console.log(gameInfos);
  let viewableResults = gameInfos.slice(
    currentPage * pageSize,
    (currentPage + 1) * pageSize,
  );
  console.log(viewableResults);

  function previousPage() {
    currentPage = Math.max(0, currentPage - 1);
  }

  function nextPage() {
    currentPage = Math.min(numPages - 1, currentPage + 1);
  }
</script>

<table class="game-info-table table is-fullwidth is-striped is-hoverable">
  <thead>
    <tr>
      <th>Date</th>
      <th>Red Player</th>
      <th>Black Player</th>
      <th>Opening</th>
      <th>Result</th>
      <th>Event</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    {#each viewableResults as game}
      <tr>
        <td>{new Date(game.date).toDateString()}</td>
        <td>{game.redPlayer}</td>
        <td>{game.blackPlayer}</td>
        <td>{game.openingCode} - {game.openingName}</td>
        <td>{game.result}</td>
        <td>{game.event}</td>
        <td />
      </tr>
    {/each}
  </tbody>
</table>
<nav
  class="table-pagination pagination"
  role="navigation"
  aria-label="pagination"
>
  <ul class="pagination-list" />
  <button class="pagination-previous" on:click={previousPage}>Previous</button>
  <button class="pagination-next" on:click={nextPage}>Next</button>
</nav>

<style lang="scss">
  .game-info-table {
    width: 100%;
  }

  .table-pagination {
    margin-top: auto;
  }
</style>
