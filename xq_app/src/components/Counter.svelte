<script lang="ts">
  let count = 0;
</script>

<button on:click={() => (count -= 1)}>-</button>
<span>{count}</span>
<button on:click={() => (count += 1)}>+</button>
