<script lang="ts">
  import { operationStore, query, getClient } from '@urql/svelte';
  import type { GameInfo } from 'utils/game';

  type Opening = {
    id: string;
    name: string;
  };

  const openingStore = operationStore<{ openings: ArrayLike<Opening> }>(`
    query getOpenings {
      openings {
        id
        name
      }
    }
  `);
  const resp = query(openingStore);

  const client = getClient();

  export let gameInfos: GameInfo[];

  let redPlayer: string | undefined;
  let blackPlayer: string | undefined;
  let opening: string | undefined;
  let result: string | undefined;
  let limit = 10;

  // TODO: opening -> openingID
  const searchQuery = `
    query searchGames(
      $redPlayer: String
      $blackPlayer: String
      $openingCode: String
      $result: String
      $limit: Int
    ) {
      games(
        redPlayer: $redPlayer
        blackPlayer: $blackPlayer
        openingCode: $openingCode
        result: $result
        limit: $limit
      ) {
        redPlayer
        blackPlayer
        result
        event
        date
        openingCode
        openingName
      }
    }
  `;

  async function searchGames() {
    const resp = await client
      .query(
        searchQuery,
        {
          redPlayer,
          blackPlayer,
          openingCode: opening?.split('-')?.[0].trim(),
          result,
          limit,
        },
        {
          requestPolicy: 'network-only', // Always resend search (for now)
        },
      )
      .toPromise();

    console.log(resp.data);

    gameInfos = resp.data.games;
  }
</script>

<div class="search-form p-5">
  <div class="field is-grouped">
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
  </div>
  <div class="field">
    <div class="control">
      <button class="button is-link" on:click={searchGames}>Search</button>
    </div>
  </div>
</div>

<style lang="scss">
  .search-form {
    height: 100%;
  }
</style>
