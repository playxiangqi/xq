function range(from: number, to: number, step: number = 1) {
  return [...Array(Math.floor((to - from) / step) + 1)].map(
    (_, i) => from + i * step,
  );
}

function strictEquals(a: [number, number], b: [number, number]) {
  return a[0] === b[0] && a[1] === b[1];
}

export default {
  range,
  strictEquals,
};
