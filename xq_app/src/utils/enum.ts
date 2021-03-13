function range(from: number, to: number, step = 1): number[] {
  return [...Array(Math.floor((to - from) / step) + 1)].map(
    (_, i) => from + i * step,
  );
}

function strictEquals(a: [number, number], b: [number, number]): boolean {
  return a[0] === b[0] && a[1] === b[1];
}

export default {
  range,
  strictEquals,
};
