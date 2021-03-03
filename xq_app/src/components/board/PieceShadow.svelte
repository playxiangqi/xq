<script lang="ts">
  export let size: number;
  export let radius: number;
  export let prevPosition: [number, number];
  export let stroke = 'black';
  export let fill = 'black';
  export let opacity = 0.1;

  $: [posY, posX] = prevPosition;
  $: [height, width] = [size * 2, size * 2];
  $: r = radius * 0.5;
  $: transform = `translate(${275 / r}, ${275 / r})`;
</script>

<svg class="piece-shadow-prev" {height} {width} y={posY} x={posX} {transform}>
  <circle {r} cx={r} cy={r} {stroke} {fill} {opacity} {transform} />
</svg>
