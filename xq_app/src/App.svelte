<script>
  export let name;

  import Board from './Board.svelte';
  import Counter from './Counter.svelte';
</script>

<h1>Hello {name}!</h1>
<Counter />
<Board />

<style>
  h1 {
    color: black;
  }
</style>
