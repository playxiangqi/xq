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
