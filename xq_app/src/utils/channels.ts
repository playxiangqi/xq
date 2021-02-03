import { Socket } from 'phoenix';

let socket = new Socket('/socket');
socket.connect();

export type PhoenixEvent = (
  event: string,
  payload: Record<string, any>
) => void;

export function createChannel(topic: string, onMessage: PhoenixEvent) {
  const channel = socket.channel(topic, { client: 'browser' });

  channel.onMessage = (event, payload) => {
    if (event != null && payload != null) {
      onMessage(event, payload);
    }

    return payload;
  };

  channel
    .join()
    .receive('ok', ({ messages }) => {
      console.log(`successfully joined channel ${topic}`);
    })
    .receive('error', ({ reason }) => {
      console.error(`failed to join channel ${topic}: ${reason}`);
    });

  return (event: string, payload: Record<string, any>) =>
    channel.push(event, payload);
}
