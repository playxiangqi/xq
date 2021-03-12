<script lang="ts">
  import { params } from '@roxi/routify';
  import GameReview from '@xq/views/analysis/GameReview.svelte';
</script>

<GameReview gameID={$params.id} />
