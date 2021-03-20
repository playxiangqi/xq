<script context="module" lang="ts">
  import { writable as svelteWritable } from 'svelte/store';
  import produce from 'immer';

  export function writable<T>(value: T) {
    const store = svelteWritable(value);

    function set(newValue: T) {
      if (newValue !== value) {
        store.set((value = newValue));
      }
    }

    return {
      set,
      update: (fn: (state: T) => void) => set(produce(value, fn)),
      subscribe: store.subscribe,
    };
  }
</script>
