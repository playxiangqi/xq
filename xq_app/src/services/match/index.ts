import { Push } from 'phoenix';
import { writable } from 'svelte/store';
import { createChannel, PhoenixEvent } from 'utils/channel';

// TODO: create, find, (quit?), options - rated/unrated/time controls/variants
export class MatchService {
  /**
   * createNewMatch
   */
  public createNewMatch(): Match {
    return new Match('testMatchID');
  }
}

type MatchState = {};

export class Match {
  private store: MatchState;
  private broadcast: PhoenixEvent;

  stop: () => Push;

  constructor(matchID: string) {
    const { broadcast, leaveChannel } = createChannel(
      `match:${matchID}`,
      (event, payload) => {}
    );

    this.store = writable({});
    this.broadcast = broadcast;
    this.stop = leaveChannel;
  }
}
