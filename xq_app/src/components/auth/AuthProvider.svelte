<script lang="ts">
  import { createChannel } from '../../utils/channels';

  const broadcast = createChannel(
    'user:guest',
    (event: string, payload: any) => {
      console.log(`event: ${event}, payload: `, payload);
    }
  );
</script>
