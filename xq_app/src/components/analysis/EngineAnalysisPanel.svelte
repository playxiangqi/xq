<script lang="ts">
  import { onDestroy } from 'svelte';
  import {
    Accordion,
    AccordionItem,
    SkeletonText,
  } from 'carbon-components-svelte';
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

<div class="engine-analysis-panel">
  <div class="content-container">
    <Accordion size="sm">
      <AccordionItem open={true}>
        <h5 slot="title">Engine Analysis - Fairy-Stockfish</h5>
        <p class="engine-metadata">
          depth={depth}/15 knps={knps}
        </p>
        {#if lines}
          {#each lines as line, i}
            <div class="top-results panel-block">
              <span
                class={`score tag ${cpScoreClassName(
                  metadata[i].scorecp,
                )} mr-2`}>{formatCPScore(metadata[i].scorecp)}</span
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
          <SkeletonText paragraph />
        {/if}
      </AccordionItem>
      <AccordionItem>
        <h5 slot="title">Engine Settings</h5>
      </AccordionItem>
    </Accordion>
  </div>
</div>

<style lang="scss">
  .engine-analysis-panel {
    .content-container {
      min-height: 700px;
      height: 700px;

      .score {
        font-weight: bold;
      }
    }
  }
</style>
