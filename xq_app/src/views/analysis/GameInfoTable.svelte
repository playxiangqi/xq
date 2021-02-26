<script lang="ts">
  import type { GameInfo } from 'utils/game';

  export let gameInfos: GameInfo[];
  export let pageSize = 14;

  let currentPage = 0;

  $: numPages = Math.floor(gameInfos.length / pageSize);
  $: viewableResults = gameInfos.slice(
    currentPage * pageSize,
    (currentPage + 1) * pageSize,
  );

  function previousPage() {
    currentPage = Math.max(0, currentPage - 1);
  }

  function nextPage() {
    currentPage = Math.min(gameInfos.length - 1, currentPage + 1);
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
      <th>Analysis</th>
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
  <button
    class="pagination-previous"
    on:click={previousPage}
    disabled={currentPage <= 0}>Previous</button
  >
  <button
    class="pagination-next"
    on:click={nextPage}
    disabled={currentPage >= numPages}>Next</button
  >
</nav>

<style lang="scss">
  .game-info-table {
    width: 100%;
  }

  .table-pagination {
    margin-top: auto;
  }
</style>
