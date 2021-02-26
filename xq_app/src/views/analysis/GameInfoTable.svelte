<script lang="ts">
  import type { GameInfo } from 'utils/game';
  import pagination from 'utils/pagination';

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
  class="table-pagination pagination is-centered"
  role="navigation"
  aria-label="pagination"
>
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
  <ul class="pagination-list">
    {#each pagination(currentPage + 1, numPages + 1) as pageNum}
      <li>
        {#if pageNum === '...'}
          <span class="pagination-ellipsis">&hellip;</span>
        {:else}
          <button
            class="pagination-link"
            aria-label={`Goto page ${pageNum}`}
            on:click={() => (currentPage = Number(pageNum) - 1)}
            disabled={currentPage === Number(pageNum) - 1}>{pageNum}</button
          >
        {/if}
      </li>
    {/each}
  </ul>
</nav>

<style lang="scss">
  .game-info-table {
    width: 100%;
  }

  .table-pagination {
    width: 100%;

    margin-top: auto;
  }
</style>
