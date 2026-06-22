const API_BASE = "/api/v1";

interface Envelope<T> {
  success: boolean;
  data: T;
}

export interface ParentOverview {
  student: {
    studentNo: string;
    user: { name: string };
    class?: { name: string } | null;
    grade?: { name: string } | null;
    assignedSeat?: { seatNo: string } | null;
  } | null;
  todayAttendance: {
    attendanceStatus: string;
    checkInAt: string | null;
    checkOutAt: string | null;
    stayMinutes: number;
  } | null;
  todayMetric: {
    studyMinutes: number;
    targetMinutes: number;
    achievedRate: string;
    pagesCompleted: number;
    problemsSolved: number;
  } | null;
  todayPlans: Array<{
    id: string;
    subjectName: string;
    title: string;
    targetMinutes: number;
    progressRate: string;
    status: string;
  }>;
}

export interface ParentAttendance {
  id: string;
  attendanceDate: string;
  attendanceStatus: string;
  checkInAt: string | null;
  checkOutAt: string | null;
  stayMinutes: number;
}

export interface ParentStudyReport {
  totalStudyMinutes: number;
  averageAchievedRate: number;
  totalPagesCompleted: number;
  totalProblemsSolved: number;
  recentMetrics: Array<{
    id: string;
    metricDate: string;
    studyMinutes: number;
    targetMinutes: number;
    achievedRate: string;
  }>;
  recentLogs: Array<{
    id: string;
    logDate: string;
    subjectName: string;
    title: string;
    studyMinutes: number;
    pagesCompleted: number;
    problemsSolved: number;
  }>;
}

export interface ParentActionReport {
  report: {
    id: string;
    message: string;
    expiresAt: string;
    viewedAt: string;
    createdAt: string;
  };
  task: {
    id: string;
    taskDate: string;
    reasonType: string;
    severity: string;
    status: string;
    message: string;
    sourceSnapshot: Record<string, unknown>;
  };
  student: {
    id: string;
    studentNo: string;
    name: string;
    gradeName: string | null;
    className: string | null;
    groupName: string | null;
  };
  todayAttendance: {
    attendanceStatus: string;
    checkInAt: string | null;
    checkOutAt: string | null;
    stayMinutes: number;
  } | null;
  todayMetric: {
    metricDate: string;
    studyMinutes: number;
    targetMinutes: number;
    achievedRate: string;
    pagesCompleted: number;
    problemsSolved: number;
  } | null;
  todayMission: {
    title: string;
    subjectName: string;
    targetMinutes: number;
    status: string;
  } | null;
  recentMetrics: Array<{
    id: string;
    metricDate: string;
    studyMinutes: number;
    targetMinutes: number;
    achievedRate: string;
  }>;
  focusSummary: {
    eventCount: number;
    returnCount: number;
    totalAwaySeconds: number;
    longestAwaySeconds: number;
    averageReturnSeconds: number;
    lastEventAt: string | null;
  } | null;
}

export interface ParentConsultationReport {
  report: {
    id: string;
    message: string;
    expiresAt: string;
    viewedAt: string;
    createdAt: string;
  };
  student: {
    id: string;
    studentNo: string;
    name: string;
    gradeName: string | null;
    className: string | null;
    groupName: string | null;
  };
  guardian: {
    id: string;
    name: string;
    relation: string;
  } | null;
  consultation: {
    id: string;
    contactType: string;
    direction: string;
    occurredAt: string;
    summary: string;
    detail: string | null;
    promisedAction: string | null;
    followUps: Array<{
      id: string;
      title: string;
      dueAt: string;
      status: string;
    }>;
  };
  recentMetrics: Array<{
    id: string;
    metricDate: string;
    studyMinutes: number;
    targetMinutes: number;
    achievedRate: string;
  }>;
  recentAttendances: Array<{
    id: string;
    attendanceDate: string;
    attendanceStatus: string;
    stayMinutes: number;
  }>;
  todayMission: {
    title: string;
    subjectName: string;
    targetMinutes: number;
    status: string;
  } | null;
  focusSummary: {
    eventCount: number;
    returnCount: number;
    averageReturnSeconds: number;
    longestAwaySeconds: number;
  } | null;
}

function tokenFromStorage() {
  if (typeof window === "undefined") return "";
  const tokenFromUrl = new URLSearchParams(window.location.search).get("token");
  if (tokenFromUrl) {
    sessionStorage.setItem("parentAccessToken", tokenFromUrl);
    return tokenFromUrl;
  }
  return sessionStorage.getItem("parentAccessToken") ?? "";
}

export function rememberToken(token: string) {
  if (typeof window !== "undefined" && token) {
    sessionStorage.setItem("parentAccessToken", token);
  }
}

export function getParentToken() {
  return tokenFromStorage();
}

async function parentFetch<T>(path: string): Promise<T> {
  const token = tokenFromStorage();
  const res = await fetch(`${API_BASE}${path}`, {
    cache: "no-store",
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!res.ok) {
    throw new Error(res.status === 401 ? "링크가 만료되었거나 유효하지 않습니다." : "리포트를 불러오지 못했습니다.");
  }
  const body = (await res.json()) as Envelope<T>;
  return body.data;
}

export function getOverview() {
  return parentFetch<ParentOverview>("/parent/student/overview");
}

export function getAttendance() {
  return parentFetch<ParentAttendance[]>("/parent/student/attendance");
}

export function getStudyReport() {
  return parentFetch<ParentStudyReport>("/parent/student/study-report");
}

export async function getActionReport(token: string) {
  const qs = new URLSearchParams({ token });
  const res = await fetch(`${API_BASE}/parent/action-report?${qs}`, {
    cache: "no-store",
  });
  if (!res.ok) {
    throw new Error(
      res.status === 401
        ? "링크가 만료되었거나 유효하지 않습니다."
        : "조치 리포트를 불러오지 못했습니다.",
    );
  }
  const body = (await res.json()) as Envelope<ParentActionReport>;
  return body.data;
}

export async function getConsultationReport(token: string) {
  const qs = new URLSearchParams({ token });
  const res = await fetch(`${API_BASE}/parent/consultation-report?${qs}`, {
    cache: "no-store",
  });
  if (!res.ok) {
    throw new Error(
      res.status === 401
        ? "링크가 만료되었거나 유효하지 않습니다."
        : "상담 리포트를 불러오지 못했습니다.",
    );
  }
  const body = (await res.json()) as Envelope<ParentConsultationReport>;
  return body.data;
}
