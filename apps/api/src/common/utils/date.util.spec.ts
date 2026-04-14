import { diffMinutes, monthKey } from './date.util';

describe('date util', () => {
  it('calculates minutes difference', () => {
    const start = new Date('2026-04-14T10:00:00+09:00');
    const end = new Date('2026-04-14T10:45:00+09:00');

    expect(diffMinutes(start, end)).toBe(45);
  });

  it('formats month key', () => {
    expect(monthKey('2026-04-14')).toBe('2026-04');
  });
});
