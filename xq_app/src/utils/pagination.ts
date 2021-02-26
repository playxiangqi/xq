import { range } from './enum';

export default function (current: number, last: number) {
  const delta = 2;
  const [left, right] = [current - delta, current + delta + 1];

  const numbered = range(2, last).filter(
    (i) => i === last || (i >= left && i < right),
  );

  let l = 1;
  return numbered.reduce<(string | number)[]>(
    (acc, i) => {
      if (i - l === 2) {
        acc = [...acc, l + 1];
      } else if (i - l !== 1) {
        acc = [...acc, '...'];
      }
      l = i;
      return [...acc, i];
    },
    [1],
  );
}
