import { calculateStudyTimePoints } from './points.util';

describe('calculateStudyTimePoints', () => {
  it('returns zero for invalid or empty durations', () => {
    expect(calculateStudyTimePoints(0)).toBe(0);
    expect(calculateStudyTimePoints(-10)).toBe(0);
  });

  it('awards 100 points per hour on a prorated basis', () => {
    expect(calculateStudyTimePoints(1800)).toBe(50);
    expect(calculateStudyTimePoints(3600)).toBe(100);
    expect(calculateStudyTimePoints(5400)).toBe(150);
  });
});
