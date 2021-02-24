<script lang="ts">
  import type { GameInfo } from 'utils/game';

  export let gameInfos: GameInfo[];
</script>

<table class="table is-fullwidth is-striped is-hoverable">
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
    {#each gameInfos as game}
      <tr>
        <th>{game.date}</th>
        <th>{game.redPlayer}</th>
        <th>{game.blackPlayer}</th>
        <th>{game.openingCode} - {game.openingName}</th>
        <th>{game.result}</th>
        <th>{game.event}</th>
        <th />
      </tr>
    {/each}
  </tbody>
</table>
