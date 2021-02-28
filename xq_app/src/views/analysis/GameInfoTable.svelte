<script lang="ts">
  import { link } from 'svelte-spa-router';
  import type { GameInfo } from 'utils/game';
  import pagination from 'utils/pagination';

  export let gameInfos: GameInfo[];
  export let pageSize = 15;

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

<table
  class="game-info-table table is-fullwidth is-striped is-hoverable is-narrow"
>
  <thead>
    <tr>
      <th>Date</th>
      <th>Red Player</th>
      <th>Black Player</th>
      <th>Opening</th>
      <th>Result</th>
      <th>Event</th>
      <th>Moves</th>
      <th />
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
        <td>{Math.floor(game.turnCount / 2)}</td>
        <td>
          <div class="action-buttons field has-addons">
            <p class="control">
              <a
                class="button is-small"
                href={`/analysis/game/${game.id}`}
                use:link
              >
                <span class="icon">
                  <i class="fas fa-game-board" />
                </span>
              </a>
            </p>
          </div>
        </td>
      </tr>
    {/each}
  </tbody>
</table>
<nav
  class="table-pagination pagination is-left"
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
            on:click={() => (currentPage = pageNum - 1)}
            disabled={currentPage === pageNum - 1}>{pageNum}</button
          >
        {/if}
      </li>
    {/each}
  </ul>
</nav>

<style lang="scss">
  .game-info-table {
    width: 100%;

    .action-buttons {
      visibility: hidden;
    }

    tr:hover td > .action-buttons {
      visibility: visible;
    }

    td {
      vertical-align: middle;
    }
  }

  .table-pagination {
    width: 100%;

    margin-top: auto;
  }
</style>
