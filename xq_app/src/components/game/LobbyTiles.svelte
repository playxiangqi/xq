<script lang="ts">
  import { Grid, Row, Column, ClickableTile } from 'carbon-components-svelte';
</script>

<div class="lobby-tiles">
  <Grid>
    <Row>
      <Column>
        <ClickableTile>Online</ClickableTile>
      </Column>
      <Column>
        <ClickableTile>Computer</ClickableTile>
      </Column>
    </Row>
  </Grid>
</div>
