export const STUDY_TIME_POINTS_PER_HOUR = 100;

export function calculateStudyTimePoints(studySeconds: number): number {
  if (studySeconds <= 0) {
    return 0;
  }

  return Math.floor((studySeconds * STUDY_TIME_POINTS_PER_HOUR) / 3600);
}
