<script context="module" lang="ts">
  export type GameSettings = {
    moveNotation: 'axf';
    pieceNotation: 'alphabetic' | 'figurine' | 'traditional';
  };
</script>

<script lang="ts">
  import { createEventDispatcher, getContext } from 'svelte';
  import {
    Accordion,
    AccordionItem,
    Button,
    ButtonSet,
    Form,
    FormGroup,
    Modal,
    RadioButton,
    RadioButtonGroup,
  } from 'carbon-components-svelte';
  import { operationStore, query } from '@urql/svelte';
  import { createBoardStore } from '@xq/core/board';
  import { GameDetails, MoveList } from '@xq/core/game';
  import { GET_GAME_BOARD_STATES_QUERY } from './queries';
  import {
    Rotate16,
    SettingsAdjust16,
    SkipBack16,
    SkipBackFilled16,
    SkipForward16,
    SkipForwardFilled16,
  } from 'carbon-icons-svelte';
  import { createAnalysisStore } from './store.svelte';

  // Props
  export let currentTurnIndex = 0;
  export let gameID: number | string;
  export let analysisStore: ReturnType<typeof createAnalysisStore>;
  export let boardStore: ReturnType<typeof createBoardStore>;
  export let gameSettings: GameSettings;

  // Initialization
  const dispatch = createEventDispatcher();
  const { playSound } = getContext('audio');
  const { transitionMoveWithinLine } = analysisStore;
  const { flipBoard } = boardStore;

  const opStore = operationStore(GET_GAME_BOARD_STATES_QUERY(gameID));
  const resp = query(opStore);

  // Reactive
  $: if (!$opStore.fetching && !$opStore.stale) {
    dispatch('receipt:board-states', $opStore.data?.game?.boards);
  }
  $: maxTurnIndex = $analysisStore.primaryLine.length - 1;
  $: gameInfo = $resp.data?.game?.info;
  $: buttons = [
    {
      icon: Rotate16,
      iconDescription: 'Flip Board',
      onClick: flipBoard,
    },
    {
      icon: SkipBack16,
      iconDescription: 'Skip to Beginning',
      disabled: currentTurnIndex <= 0,
      onClick: updateTurn(skipToBeginning),
    },
    {
      icon: SkipBackFilled16,
      iconDescription: 'Previous Move',
      disabled: currentTurnIndex <= 0,
      onClick: updateTurn(previousMove),
    },
    {
      icon: SkipForwardFilled16,
      iconDescription: 'Next Move',
      disabled: currentTurnIndex >= maxTurnIndex,
      onClick: updateTurn(nextMove),
    },
    {
      icon: SkipForward16,
      iconDescription: 'Skip to End',
      disabled: currentTurnIndex >= maxTurnIndex,
      onClick: updateTurn(skipToEnd),
    },
    {
      icon: SettingsAdjust16,
      iconDescription: 'Settings',
      onClick: () => (settingsModalOpen = true),
    },
  ];

  // Locals
  let moveList: MoveList;
  // TODO: Move board controls and modal to a separate component(s)
  //       Need to figure out if it should be categorized/placed in
  //       game/analysis/board
  let settingsModalOpen = false;
  let { moveNotation, pieceNotation } = gameSettings;

  // Event Handlers
  function updateTurn(eventHandler: () => void) {
    const DEBOUNCE_DELAY = 500;
    let timer: number;

    return () => {
      // Run turn-based handler
      eventHandler();

      // Update UI
      transitionMoveWithinLine(currentTurnIndex);
      moveList.scrollIntoView(currentTurnIndex);

      // Debounce engine analysis
      clearTimeout(timer);
      timer = setTimeout(
        () => dispatch('update:turn', $boardStore.workingLayout),
        DEBOUNCE_DELAY,
      );
    };
  }

  function skipToBeginning() {
    currentTurnIndex = 0;
    // TODO: reset turn to red, because grabbing pieces while using the
    //       move replay puts things out of sync
  }

  // TODO: in prevMove and nextMove, need to toggle turns as well
  //       also need to support grab/drop piece actions that generate
  //       separate moves/board state array that branches off from the
  //       prepared game analysis board state
  function previousMove() {
    currentTurnIndex = Math.max(0, currentTurnIndex - 1);
    playSound();
  }

  function nextMove() {
    currentTurnIndex = Math.min(maxTurnIndex, currentTurnIndex + 1);
    playSound();
  }

  function skipToEnd() {
    currentTurnIndex = maxTurnIndex;
  }

  function gotoTurn(turnIndex: number) {
    return updateTurn(() => {
      currentTurnIndex = turnIndex;
    });
  }

  function saveGameSettings() {
    settingsModalOpen = false;
    dispatch('save:game-settings', { moveNotation, pieceNotation });
  }
</script>

<div class="game-info-panel">
  <div class="game-details-container">
    {#if $resp.fetching}
      <Accordion skeleton count={3} size="sm" />
    {:else}
      <Accordion size="sm">
        <AccordionItem open={true}>
          <h5 slot="title">Game Details</h5>
          <GameDetails {gameInfo} />
        </AccordionItem>
        <AccordionItem open={true}>
          <h5 slot="title">Moves</h5>
          <MoveList
            bind:this={moveList}
            {currentTurnIndex}
            {maxTurnIndex}
            moves={gameInfo.moves}
            {gotoTurn}
          />
        </AccordionItem>
        <AccordionItem>
          <h5 slot="title">Board Setup</h5>
        </AccordionItem>
      </Accordion>
    {/if}
  </div>
  <div class="move-buttons">
    <ButtonSet>
      {#each buttons as { icon, iconDescription, onClick, disabled }}
        <Button
          class="move-button"
          kind="tertiary"
          tooltipPosition="top"
          hasIconOnly
          {icon}
          {iconDescription}
          {disabled}
          on:click={onClick}
        />
      {/each}
    </ButtonSet>
  </div>
</div>

<Modal
  bind:open={settingsModalOpen}
  modalHeading="Settings"
  primaryButtonText="Save"
  secondaryButtonText="Cancel"
  hasForm
  on:submit={saveGameSettings}
  on:click:button--secondary={() => (settingsModalOpen = false)}
  on:open
  on:close
  on:submit
  shouldSubmitOnEnter={false}
>
  <!-- TODO: Enumerate options based on type union -->
  <Form>
    <FormGroup legendText="Move Notation">
      <RadioButtonGroup bind:selected={moveNotation}>
        <RadioButton labelText="AXF" value="axf" />
      </RadioButtonGroup>
    </FormGroup>
    <FormGroup legendText="Piece Notation">
      <RadioButtonGroup bind:selected={pieceNotation}>
        <RadioButton labelText="Alphabetic" value="alphabetic" />
        <RadioButton labelText="Figurine" value="figurine" />
        <RadioButton labelText="Traditional" value="traditional" />
      </RadioButtonGroup>
    </FormGroup>
  </Form>
</Modal>

<style lang="scss">
  .game-info-panel {
    position: relative;
    height: 100%;

    .game-details-container {
      max-height: 600px;
    }

    .move-buttons {
      /* max-width: 100%; */

      position: absolute;
      bottom: 0px;

      :global(.move-button.bx--btn.bx--btn--tertiary) {
        width: 60px;

        padding-left: 20px;
        padding-right: 20px;
      }
    }
  }
</style>
