import { subscriptionExchange } from '@urql/core';
import { Channel, Socket } from 'phoenix';
import { make, pipe, toObservable } from 'wonka';

const socket = new Socket('/socket');
socket.connect();

export type PhoenixPayload = Record<string, any>;

export type PhoenixEventHandler = (
  event: string,
  payload: PhoenixPayload,
) => void;

export function connect(topic: string, onMessage: PhoenixEventHandler) {
  const channel = socket.channel(topic, { client: 'browser' });

  channel.onMessage = (event, payload) => {
    if (event != null && payload != null) {
      onMessage(event, payload);
    }

    return payload;
  };

  channel
    .join()
    .receive('ok', () => {
      console.log(`successfully joined channel ${topic}`);
    })
    .receive('error', ({ reason }) => {
      console.error(`failed to join channel ${topic}: ${reason}`);
    });

  return {
    push: (event: string, payload: PhoenixPayload) =>
      channel.push(event, payload),
    leave: () => channel.leave(),
  };
}

const absintheChannel = socket.channel('__absinthe__:control');
absintheChannel.join();

export const absintheExchange = subscriptionExchange({
  forwardSubscription({ query, variables }) {
    let subscriptionChannel: Channel;

    const source = make((observer) => {
      const { next } = observer;

      absintheChannel
        .push('doc', { query, variables })
        .receive('ok', ({ subscriptionId }) => {
          if (subscriptionId) {
            subscriptionChannel = socket.channel(subscriptionId);
            subscriptionChannel.on('subscription:data', (value) => {
              next(value.result);
            });
          }
        });

      return () => {
        subscriptionChannel?.leave();
      };
    });

    return pipe(source, toObservable);
  },
});

export default { connect };
