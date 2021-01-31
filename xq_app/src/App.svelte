<script>
  export let name;

  import Counter from './components/Counter.svelte';
</script>

<h1>Hello {name}!</h1>
<Counter />

<style>
  h1 {
    color: black;
  }
</style>
