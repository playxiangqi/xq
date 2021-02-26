export function range(from: number, to: number, step: number = 1) {
  return [...Array(Math.floor((to - from) / step) + 1)].map(
    (_, i) => from + i * step,
  );
}
