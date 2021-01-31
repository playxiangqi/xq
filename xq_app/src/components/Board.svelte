<script>
  import BoardSVG from '../../assets/svg/xiangqi-board.min.svg';

  import Piece from './Piece.svelte';
  import { ADVISOR_RED } from './glyphs/traditional';
</script>

<div class="board-container">
  <div class="board-frame">
    <BoardSVG />
  </div>
  <Piece side="red" glyph={ADVISOR_RED} />
</div>

<style lang="scss">
  .board-container {
    .board-frame > :global(svg) {
      background-color: #fcaf3e;
      border: solid 2px black;
    }
  }
</style>
