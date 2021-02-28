<script lang="ts">
  import { operationStore, query, getClient } from '@urql/svelte';
  import type { GameInfo, Opening } from 'utils/game';
  import { GET_OPENINGS_QUERY, SEARCH_GAMES_QUERY } from './queries';

  export let gameInfos: GameInfo[];

  const client = getClient();

  const openingStore = operationStore<{ openings: ArrayLike<Opening> }>(
    GET_OPENINGS_QUERY,
  );
  const resp = query(openingStore);

  let redPlayer: string | undefined;
  let blackPlayer: string | undefined;
  let opening: string | undefined;
  let result: string | undefined;
  let limit = 10;
  let minMoves: number | undefined;
  let maxMoves: number | undefined;

  async function searchGames() {
    const resp = await client
      .query(
        SEARCH_GAMES_QUERY,
        {
          redPlayer,
          blackPlayer,
          openingCode: opening?.split('-')?.[0].trim(),
          result,
          limit,
          minMoves,
          maxMoves,
        },
        {
          requestPolicy: 'network-only', // Always resend search (for now)
        },
      )
      .toPromise();

    gameInfos = resp.data.games;
  }
</script>

<div class="search-form p-2">
  <div class="search-form-field field is-grouped">
    <div class="control red-player-input">
      <label for="red-player-input" class="label">Player</label>
      <input
        class="input"
        type="text"
        placeholder="Red Player"
        bind:value={redPlayer}
      />
    </div>
    <div class="control black-player-input">
      <label for="black-player-input" class="label is-invisible">
        Player
      </label>
      <input
        class="input"
        type="text"
        placeholder="Black Player"
        bind:value={blackPlayer}
      />
    </div>
    <div class="control opening-dropdown">
      <label for="opening-dropdown" class="label">Opening</label>
      {#if $resp.fetching}
        <div class="select is-loading">
          <select />
        </div>
      {:else}
        <div class="select">
          <select bind:value={opening}>
            {#each resp.data?.openings || [] as o}
              <option>{o.id} - {o.name}</option>
            {/each}
          </select>
        </div>
      {/if}
    </div>
    <div class="control">
      <label for="result-dropdown" class="label">Result</label>
      <div class="select">
        <select bind:value={result}>
          {#each ['Red Victory', 'Draw', 'Black Victory'] as o}
            <option>{o}</option>
          {/each}
        </select>
      </div>
    </div>
    <div class="move-count-field field is-grouped">
      <div class="control move-count-min-input">
        <label for="move-count-min-input" class="label">Moves</label>
        <input
          class="input numeric-input"
          type="number"
          placeholder="Min"
          min="0"
          max="500"
          bind:value={minMoves}
        />
      </div>
      <div class="control move-count-max-input">
        <label for="move-count-max-input" class="label is-invisible">
          Max Moves
        </label>
        <input
          class="input numeric-input"
          type="number"
          placeholder="Max"
          min="0"
          max="500"
          bind:value={maxMoves}
        />
      </div>
      <div class="control limit-dropdown">
        <label for="limit-input" class="label">Limit</label>
        <div class="select">
          <select bind:value={limit}>
            {#each [10, 25, 50, 100] as o}
              <option>{o}</option>
            {/each}
          </select>
        </div>
      </div>
      <div class="control ml-3">
        <label for="search-button" class="label is-invisible">Search</label>
        <button class="button is-link" on:click={searchGames}>Search</button>
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  .search-form {
    height: 100%;

    .search-form-field {
      margin-top: -15px;

      flex-direction: row;
      flex-wrap: wrap;

      & > * {
        margin-top: 15px;
      }
    }

    .numeric-input {
      width: 100px;
    }
  }
</style>
