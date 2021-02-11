<script lang="ts">
</script>

<div class="panel search-panel">
  <p class="panel-heading">Database Explorer</p>
  <div class="p-5 search-form-container">
    <label for="red-player-input" class="label">Player</label>
    <div class="field is-horizontal">
      <div class="control red-player-input">
        <input class="input" type="text" placeholder="Red Player" />
      </div>
      <span class="m-2">vs.</span>
      <div class="control black-player-input">
        <input class="input" type="text" placeholder="Black Player" />
      </div>
    </div>
    <div class="field">
      <label for="opening-input" class="label">Opening</label>
      <div class="control opening-input">
        <input class="input" type="text" placeholder="Elephant Opening" />
      </div>
    </div>
    <div class="field">
      <label for="source-dropdown" class="label">Source</label>
      <div class="control">
        <div class="select">
          <select>
            <option>Play XiangQi</option>
            <option>01xq</option>
          </select>
        </div>
      </div>
    </div>
    <div class="field">
      <label for="result-dropdown" class="label">Result</label>
      <div class="control">
        <div class="select">
          <select>
            <option>Red Victory</option>
            <option>Draw</option>
            <option>Black Victory</option>
          </select>
        </div>
      </div>
    </div>
    <div class="field">
      <label for="game-id-input" class="label">Exact Game ID</label>
      <div class="control game-id-input">
        <input class="input" type="text" placeholder="" />
      </div>
    </div>
    <div class="field">
      <div class="control">
        <button class="button is-link">Search</button>
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  // Just like analysis-panel but on opposite-side
  // can be redundant or maybe use some scss composition to achieve mirrored effect
  .search-panel {
    margin-left: 50px;

    .search-form-container {
      min-height: 725px;
      height: 725px;
    }
  }
</style>
