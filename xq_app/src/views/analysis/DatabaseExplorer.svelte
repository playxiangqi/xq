<script lang="ts">
  import SearchForm from './SearchForm.svelte';
</script>

<div class="database-explorer">
  <div class="col-1" />
  <div class="main-panel panel">
    <p class="panel-heading">Database Explorer</p>
    <div class="search-form-container panel-block">
      <SearchForm />
    </div>
    <div class="search-results-container panel-block">
      <table class="table is-fullwidth is-striped is-hoverable">
        <thead>
          <tr>
            <th>Date</th>
            <th>Red Player</th>
            <th>Black Player</th>
            <th>Opening</th>
            <th>Result</th>
            <th>Event</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody />
      </table>
    </div>
  </div>
  <div class="col-3" />
</div>

<style lang="scss">
  .database-explorer {
    margin-top: 15px;

    display: grid;
    grid-template-columns: 1fr 6.75fr 1fr;

    .search-results-container {
      align-items: flex-start;
      min-height: 600px;
    }
  }
</style>
