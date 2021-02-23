<script lang="ts">
  import { operationStore, query } from '@urql/svelte';

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

  let redPlayer: string | undefined;
  let blackPlayer: string | undefined;
  let opening: string | undefined;
  let result: string | undefined;
  let limit = 10;

  const searchQuery = `
    query searchGames(
      $redPlayer: String
      $blackPlayer: String
      $opening: String
      $result: String
      $limit: Int
    ) {
      game(
        redPlayer: $redPlayer
        blackPlayer: $blackPlayer
        opening: $opening
        result: $result
        limit: $limit
      ) {
        info {
          redPlayer
          blackPlayer
          result
          event
          date
          openingCode
          openingName
        }
      }
    }
  `;
  const gameInfoStore = operationStore(
    searchQuery,
    { redPlayer, limit },
    { pause: true },
  );
  query(gameInfoStore);

  function searchGames() {
    console.log(`redPlayer: ${redPlayer}`);
    console.log(`blackPlayer: ${blackPlayer}`);
    console.log(`opening: ${opening}`);
    console.log(`result: ${result}`);
    console.log(`limit: ${limit}`);

    $gameInfoStore.context = {
      ...gameInfoStore.context,
      pause: false,
    };
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
