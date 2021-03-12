import { writable } from 'svelte/store';
import { createChannel, PhoenixPayload } from '@xq/utils/channels';
import type { EngineResults } from './types';

export function createAnalysisStore(username: string) {
  const store = writable<EngineResults>({
    best_move: [],
    results: [],
  });

  function loadEngineResults(payload: PhoenixPayload) {
    // console.log('engineResults: ', payload);
    store.update(() => payload as EngineResults);
  }

  function dispatcher(event: string, payload: PhoenixPayload) {
    const dispatch: {
      [event: string]: (payload: PhoenixPayload) => void;
    } = {
      [`analysis:${username}`]: loadEngineResults,
    };

    return dispatch[event]?.(payload);
  }

  const { broadcast } = createChannel(`analysis:${username}`, dispatcher);
  const pushAnalysis = (payload: PhoenixPayload) =>
    broadcast('analysis:board_state', payload);

  return {
    store,
    pushAnalysis,
  };
}
