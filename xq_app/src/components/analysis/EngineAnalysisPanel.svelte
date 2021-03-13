<script lang="ts">
  import { onDestroy } from 'svelte';
  import Channel from '@xq/utils/channel';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import type { EngineResults } from './types';

  export let currentTurnIndex: number;
  export let username: string;
  export let pushAnalysis: (payload: PhoenixPayload) => void;

  let engineResults: EngineResults = {
    best_move: [],
    results: [],
  };
  let leaveChannel = () => {};

  $: if (username !== '') {
    const { push, leave } = Channel.connect(`analysis:${username}`, dispatcher);
    pushAnalysis = (payload: PhoenixPayload) =>
      push('analysis:board_state', payload);
    leaveChannel = leave;
  }

  onDestroy(() => leaveChannel());

  $: metadata = engineResults.results.map((v) => v.metadata);
  $: lines = engineResults.results.map((v) => v.lines);

  $: moveIndex = Math.floor(currentTurnIndex / 2);
  $: depth = metadata?.[0]?.depth ?? '0';
  $: knps = metadata?.[0]?.nps ? Math.floor(metadata[0]?.nps / 1000) : '0';

  function loadEngineResults(payload: PhoenixPayload) {
    engineResults = payload as EngineResults;
  }

  function dispatcher(event: string, payload: PhoenixPayload) {
    const dispatch: {
      [event: string]: (payload: PhoenixPayload) => void;
    } = {
      [`analysis:${username}`]: loadEngineResults,
    };

    return dispatch[event]?.(payload);
  }

  function formatCPScore(scorecp: number) {
    // TODO: Eventually keep track of side-to-move in boardState properly
    let v = scorecp / 100;
    if (currentTurnIndex % 2 != 0) {
      v = -v;
    }
    return v > 0 ? `+${v}` : v;
  }

  function cpScoreClassName(scorecp: number) {
    let v = scorecp;
    if (currentTurnIndex % 2 != 0) {
      v = -v;
    }
    return v > 0 ? 'is-danger' : v < 0 ? 'is-black' : 'is-light';
  }
</script>

<div class="panel engine-analysis-panel">
  <div class="panel-heading">Engine Analysis</div>
  <div class="panel-tabs">
    <!-- svelte-ignore a11y-missing-attribute -->
    <a class="is-active">Evaluation</a>
    <!-- svelte-ignore a11y-missing-attribute -->
    <a>Engine Settings</a>
    <!-- svelte-ignore a11y-missing-attribute -->
    <a>Board Setup</a>
  </div>
  <div class="content-container">
    <div class="engine panel-block">
      Fairy-Stockfish 11.2 LB 64 by Fabian Fichter
    </div>
    <div class="top-metadata panel-block">depth={depth} knps={knps}</div>
    {#if lines}
      {#each lines as line, i}
        <div class="top-results panel-block">
          <span
            class={`score tag ${cpScoreClassName(metadata[i].scorecp)} mr-2`}
            >{formatCPScore(metadata[i].scorecp)}</span
          >
          <p class="line">
            {#each line as [redMove, blackMove], j}
              {moveIndex + j + 1}. {redMove}
              {blackMove ?? ''}{' '}
            {/each}
          </p>
        </div>
      {/each}
    {:else}
      <div class="panel-block">Waiting for engine...</div>
    {/if}
  </div>
</div>

<style lang="scss">
  .engine-analysis-panel {
    margin-left: 50px;

    .content-container {
      min-height: 700px;
      height: 700px;

      .score {
        font-weight: bold;
      }

      /* .line {
        max-width: 400px;

        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      } */
    }
  }
</style>
