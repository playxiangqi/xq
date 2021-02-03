<script lang="ts">
  import { createAuthStore } from 'services/auth/store';

  const { store: authStore, broadcast: sendAuthRequest } = createAuthStore();
</script>

<div class="panel is-dark">
  <p class="panel-heading">Analysis</p>
  <p>Joined lobby as: {$authStore.username}</p>
</div>
