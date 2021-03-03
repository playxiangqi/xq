<script lang="ts">
  export let size: number;
  export let position: [number, number];
  export let fill = 'gray';
  export let opacity = 0.4;

  $: [posY, posX] = position;
</script>

<svg class="piece-shadow" height={size} width={size} y={posY} x={posX}>
  <rect height={size} width={size} {fill} {opacity} />
</svg>
