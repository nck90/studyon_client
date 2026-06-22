export type TvScreen =
  | "RANKING"
  | "SEAT_MAP"
  | "MESSAGE"
  | "CLOCK"
  | "GOAL_WALL";

export interface TvSettings {
  activeScreen: TvScreen;
  rotationEnabled: boolean;
  rotationIntervalSeconds: number;
  enabledScreens: TvScreen[];
  message: string;
  rankingType: string;
  periodType: string;
  updatedAt: string | null;
}

export interface DisplayStatus {
  checkedInCount: number;
  seatOccupancyRate: number;
  liveStudyMinutes: number;
  todayTotalStudyMinutes: number;
}

export interface RankingItem {
  id: string;
  studentId: string;
  rankNo: number;
  score: string;
  displayName?: string;
  student: {
    user: { name: string };
    grade?: { name: string };
    class?: { name: string };
  };
}

export interface Rankings {
  snapshot: {
    rankingType: string;
    periodType: string;
    periodKey: string;
  };
  items: RankingItem[];
}

export interface DisplaySeat {
  id: string;
  seatNo: string;
  zone: string | null;
  status: string;
  uiStatus: "empty" | "occupied" | "reserved" | "locked";
  currentStudent: { id: string; displayName: string } | null;
}

export interface Motivation {
  message: string;
  challenge: string;
  topStudent: {
    displayName?: string;
    name?: string;
    rankNo: number;
    score: number;
  } | null;
}

export interface GoalWall {
  goals: Array<{
    studentId: string;
    displayName: string;
    targetUniversityName: string;
    targetUniversityMedia: { publicUrl?: string } | null;
  }>;
  achievers: Array<{
    displayName: string;
    achievedRate: number;
    studyMinutes: number;
  }>;
}

interface ApiEnvelope<T> {
  success: boolean;
  data: T;
}

async function apiGet<T>(path: string): Promise<T> {
  const response = await fetch(`/api/v1${path}`, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  const body = (await response.json()) as ApiEnvelope<T>;
  return body.data;
}

export function getSettings() {
  return apiGet<TvSettings>("/display/current");
}

export function getStatus() {
  return apiGet<DisplayStatus>("/display/status");
}

export function getRankings(periodType: string, rankingType: string) {
  const query = new URLSearchParams({ periodType, rankingType });
  return apiGet<Rankings>(`/display/rankings?${query}`);
}

export function getSeats() {
  return apiGet<DisplaySeat[]>("/display/seats");
}

export function getMotivation() {
  return apiGet<Motivation>("/display/motivation");
}

export function getGoals() {
  return apiGet<GoalWall>("/display/goals");
}
