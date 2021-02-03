import { writable } from 'svelte/store';
import { createChannel } from '../../utils/channel';

export function createAuthStore() {
  const store = writable({ username: '' });

  const { broadcast, leaveChannel } = createChannel(
    'user:guest',
    (event: string, payload: any) => {
      if (event === 'phx_reply' && payload.status === 'ok') {
        const guestID = payload.response.guest_id;
        if (guestID != null) {
          store.set({ username: guestID });
        }
      } else {
        console.log(`event: ${event}, payload: `, payload);
      }
    }
  );

  return {
    store,
    broadcast,
  };
}
