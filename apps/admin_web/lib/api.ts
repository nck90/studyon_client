const API_BASE = "/api/v1";

interface ApiResponse<T> {
  success: boolean;
  data: T;
  meta: Record<string, unknown>;
}

function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("accessToken");
}

function getRefreshToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("refreshToken");
}

export function setTokens(access: string, refresh: string) {
  localStorage.setItem("accessToken", access);
  localStorage.setItem("refreshToken", refresh);
}

export function clearTokens() {
  localStorage.removeItem("accessToken");
  localStorage.removeItem("refreshToken");
  localStorage.removeItem("user");
}

async function refreshAccessToken(): Promise<string | null> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return null;

  try {
    const res = await fetch(`${API_BASE}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });
    if (!res.ok) return null;
    const json: ApiResponse<{ accessToken: string; refreshToken: string }> =
      await res.json();
    if (json.success) {
      setTokens(json.data.accessToken, json.data.refreshToken);
      return json.data.accessToken;
    }
    return null;
  } catch {
    return null;
  }
}

async function apiErrorMessage(res: Response, fallback: string) {
  const body = await res.json().catch(() => ({}));
  const message = (body as { message?: unknown }).message;
  if (Array.isArray(message)) return message.join("\n");
  if (typeof message === "string" && message.trim()) return message;
  return fallback;
}

async function apiFetch<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const token = getAccessToken();
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...((options.headers as Record<string, string>) ?? {}),
  };
  if (token) headers["Authorization"] = `Bearer ${token}`;

  let res = await fetch(`${API_BASE}${path}`, { ...options, headers });

  // If 401, try refresh
  if (res.status === 401 && token) {
    const newToken = await refreshAccessToken();
    if (newToken) {
      headers["Authorization"] = `Bearer ${newToken}`;
      res = await fetch(`${API_BASE}${path}`, { ...options, headers });
    } else {
      clearTokens();
      if (typeof window !== "undefined") window.location.href = "/login";
      throw new Error("Session expired");
    }
  }

  if (!res.ok) {
    throw new Error(await apiErrorMessage(res, `API error: ${res.status}`));
  }

  const json: ApiResponse<T> = await res.json();
  return json.data;
}

// ─── Auth ─────────────────────────────────────────────

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  sessionId: string;
  user: {
    id: string;
    role: string;
    name: string;
    email: string;
  };
}

export async function signup(
  name: string,
  email: string,
  password: string,
): Promise<LoginResponse> {
  const res = await fetch(`${API_BASE}/auth/admin/signup`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email, password }),
  });
  if (!res.ok) {
    throw new Error(await apiErrorMessage(res, "회원가입에 실패했습니다."));
  }
  const json: ApiResponse<LoginResponse> = await res.json();
  setTokens(json.data.accessToken, json.data.refreshToken);
  localStorage.setItem("user", JSON.stringify(json.data.user));
  return json.data;
}

export async function login(
  email: string,
  password: string,
): Promise<LoginResponse> {
  const res = await fetch(`${API_BASE}/auth/admin/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok) {
    throw new Error(await apiErrorMessage(res, "로그인에 실패했습니다."));
  }
  const json: ApiResponse<LoginResponse> = await res.json();
  setTokens(json.data.accessToken, json.data.refreshToken);
  localStorage.setItem("user", JSON.stringify(json.data.user));
  return json.data;
}

export async function logout() {
  try {
    await apiFetch("/auth/logout", { method: "POST" });
  } catch {
    // ignore
  }
  clearTokens();
}

export async function getMe() {
  return apiFetch<{
    id: string;
    role: string;
    name: string;
    adminUser?: { email: string };
  }>("/auth/me");
}

// ─── Dashboard ────────────────────────────────────────

export interface DashboardResponse {
  checkedInCount: number;
  seatOccupancyRate: number;
  availableSeatCount: number;
  notCheckedInStudents: number;
  notStartedStudyStudents: number;
  inactiveStudents: number;
}

export async function getDashboard() {
  return apiFetch<DashboardResponse>("/admin/dashboard");
}

// ─── Students ─────────────────────────────────────────

export interface StudentResponse {
  id: string;
  userId: string;
  studentNo: string;
  loginId: string;
  assignedSeatId: string | null;
  enrollmentStatus: string;
  memo: string | null;
  user: {
    id: string;
    name: string;
    status: string;
    phone: string | null;
  };
  grade: { id: string; name: string };
  class: { id: string; name: string };
  group: { id: string; name: string } | null;
  seat?: { seatNo: string } | null;
}

export async function getStudents(params?: {
  keyword?: string;
  gradeId?: string;
  classId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.keyword) qs.set("keyword", params.keyword);
  if (params?.gradeId) qs.set("gradeId", params.gradeId);
  if (params?.classId) qs.set("classId", params.classId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<StudentResponse[]>(`/admin/students${query}`);
}

export async function getStudent(studentId: string) {
  return apiFetch<StudentResponse>(`/admin/students/${studentId}`);
}

export async function createStudent(data: {
  name: string;
  studentNo: string;
  gradeId?: string;
  classId?: string;
  groupId?: string;
  assignedSeatId?: string;
}) {
  return apiFetch<StudentResponse>("/admin/students", {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function getStudentStudySummary(studentId: string) {
  return apiFetch<{
    metrics: Array<{
      metricDate: string;
      studyMinutes: number;
      attendanceMinutes: number;
      attendanceStatus: string;
    }>;
  }>(`/admin/students/${studentId}/study-summary`);
}

// ─── Seats ────────────────────────────────────────────

export interface SeatResponse {
  id: string;
  seatNo: string;
  zone: string;
  status: string; // AVAILABLE, OCCUPIED, RESERVED, LOCKED
  isActive: boolean;
  currentStudentId: string | null;
  currentStudent: { id: string; user: { name: string } } | null;
}

export async function getSeats(zone?: string, status?: string) {
  const qs = new URLSearchParams();
  if (zone) qs.set("zone", zone);
  if (status) qs.set("status", status);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<SeatResponse[]>(`/admin/seats${query}`);
}

export async function createSeat(seatNo: string, zone?: string) {
  return apiFetch<SeatResponse>("/admin/seats", {
    method: "POST",
    body: JSON.stringify({ seatNo, zone }),
  });
}

export async function updateSeat(
  seatId: string,
  status?: string,
  zone?: string,
) {
  const qs = new URLSearchParams();
  if (status) qs.set("status", status);
  if (zone) qs.set("zone", zone);
  return apiFetch<SeatResponse>(`/admin/seats/${seatId}?${qs}`, {
    method: "PATCH",
  });
}

export async function assignSeat(
  seatId: string,
  studentId: string,
  assignmentType: string,
) {
  return apiFetch<SeatResponse>(`/admin/seats/${seatId}/assign`, {
    method: "POST",
    body: JSON.stringify({ studentId, assignmentType }),
  });
}

export async function lockSeat(seatId: string) {
  return apiFetch<SeatResponse>(`/admin/seats/${seatId}/lock`, {
    method: "POST",
  });
}

export async function unlockSeat(seatId: string) {
  return apiFetch<SeatResponse>(`/admin/seats/${seatId}/unlock`, {
    method: "POST",
  });
}

export async function deleteSeat(seatId: string) {
  return apiFetch<void>(`/admin/seats/${seatId}`, { method: "DELETE" });
}

// ─── Attendances ──────────────────────────────────────

export interface AttendanceResponse {
  id: string;
  studentId: string;
  attendanceDate: string;
  checkInAt: string | null;
  checkOutAt: string | null;
  stayMinutes: number;
  attendanceStatus: string;
  lateStatus: string;
  student: {
    id: string;
    user: { name: string };
    grade: { name: string };
    class: { name: string };
  };
  seat?: { seatNo: string } | null;
}

export async function getAttendances(params?: {
  date?: string;
  classId?: string;
  attendanceStatus?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.date) qs.set("date", params.date);
  if (params?.classId) qs.set("classId", params.classId);
  if (params?.attendanceStatus)
    qs.set("attendanceStatus", params.attendanceStatus);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<AttendanceResponse[]>(`/admin/attendances${query}`);
}

export async function getAttendanceStats(params?: {
  startDate?: string;
  endDate?: string;
  classId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.startDate) qs.set("startDate", params.startDate);
  if (params?.endDate) qs.set("endDate", params.endDate);
  if (params?.classId) qs.set("classId", params.classId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<unknown>(`/admin/attendance-stats${query}`);
}

// ─── Rankings ─────────────────────────────────────────

export interface RankingItemResponse {
  id: string;
  studentId: string;
  rankNo: number;
  score: string;
  subScore1: string;
  subScore2: string;
  student: {
    id: string;
    user: { name: string };
    grade: { name: string };
    class: { name: string };
  };
}

export interface RankingsResponse {
  snapshot: {
    id: string;
    rankingType: string;
    periodType: string;
    periodKey: string;
  };
  items: RankingItemResponse[];
}

export async function getRankings(
  periodType: string = "DAILY",
  rankingType: string = "STUDY_TIME",
) {
  return apiFetch<RankingsResponse>(
    `/admin/rankings?periodType=${periodType}&rankingType=${rankingType}`,
  );
}

// ─── Notifications ────────────────────────────────────

export interface NotificationResponse {
  id: string;
  notificationType: string;
  channel: string;
  title: string;
  body: string;
  targetScope: string;
  status: string;
  scheduledAt: string | null;
  sentAt: string | null;
  createdAt: string;
}

export async function getNotifications() {
  return apiFetch<NotificationResponse[]>("/admin/notifications");
}

export async function createNotification(data: {
  title: string;
  body: string;
  notificationType?: string;
  channel?: string;
  targetScope?: string;
}) {
  return apiFetch<NotificationResponse>("/admin/notifications", {
    method: "POST",
    body: JSON.stringify({
      notificationType: "ANNOUNCEMENT",
      channel: "IN_APP",
      targetScope: "ALL",
      ...data,
    }),
  });
}

export async function sendNotification(notificationId: string) {
  return apiFetch<unknown>(`/admin/notifications/${notificationId}/send`, {
    method: "POST",
  });
}

// ─── Settings ─────────────────────────────────────────

export type TvScreen =
  | "RANKING"
  | "SEAT_MAP"
  | "MESSAGE"
  | "CLOCK"
  | "GOAL_WALL";

export interface TvDisplaySettingsResponse {
  id?: string;
  activeScreen: TvScreen | "STATUS" | "MOTIVATION";
  rotationEnabled: boolean;
  rotationIntervalSeconds: number;
  displayOptions?: {
    enabledScreens?: TvScreen[];
    message?: string;
    rankingType?: string;
    periodType?: string;
  } | null;
}

export async function getTvDisplaySettings() {
  return apiFetch<TvDisplaySettingsResponse | null>(
    "/admin/settings/tv-display",
  );
}

export async function updateTvDisplaySettings(data: Record<string, unknown>) {
  return apiFetch<unknown>("/admin/settings/tv-display", {
    method: "PATCH",
    body: JSON.stringify(data),
  });
}

export async function getAttendancePolicy() {
  return apiFetch<unknown>("/admin/settings/attendance-policy");
}

export type BadgeRuleMetric =
  | "ATTENDANCE_STREAK_DAYS"
  | "DAILY_STUDY_MINUTES"
  | "DAILY_ACHIEVED_RATE"
  | "WEEKLY_STUDY_MINUTES"
  | "MONTHLY_STUDY_MINUTES"
  | "PROBLEMS_SOLVED"
  | "PAGES_COMPLETED";

export type FocusPolicyMode =
  | "SOFT_LOCK"
  | "ANDROID_DEVICE_OWNER"
  | "IOS_SCREEN_TIME";

export interface BadgeRuleResponse {
  id: string;
  badgeId: string;
  metric: BadgeRuleMetric;
  threshold: number;
  windowDays: number | null;
  isActive: boolean;
  badge: {
    id: string;
    code: string;
    name: string;
    description: string | null;
  };
}

export interface FocusPolicyResponse {
  id: string;
  policyName: string;
  mode: FocusPolicyMode;
  isEnabled: boolean;
  blockedPackages: string[];
  allowedPackages: string[];
  graceSeconds: number;
  opsQueueThreshold: number;
  parentReportThreshold: number;
}

export async function getBadgeRules() {
  return apiFetch<BadgeRuleResponse[]>("/admin/badge-rules");
}

export async function updateBadgeRules(
  rules: Array<{
    id?: string;
    badgeId: string;
    metric: BadgeRuleMetric;
    threshold: number;
    windowDays?: number | null;
    isActive?: boolean;
  }>,
) {
  return apiFetch<BadgeRuleResponse[]>("/admin/badge-rules", {
    method: "PATCH",
    body: JSON.stringify({ rules }),
  });
}

export async function getFocusPolicy() {
  return apiFetch<FocusPolicyResponse>("/admin/focus-policy");
}

export async function updateFocusPolicy(
  data: Partial<{
    policyName: string;
    mode: FocusPolicyMode;
    isEnabled: boolean;
    blockedPackages: string[];
    allowedPackages: string[];
    graceSeconds: number;
    opsQueueThreshold: number;
    parentReportThreshold: number;
  }>,
) {
  return apiFetch<FocusPolicyResponse>("/admin/focus-policy", {
    method: "PATCH",
    body: JSON.stringify(data),
  });
}

// ─── Focus OS ────────────────────────────────────────

export type FocusStudentStatus =
  | "FOCUSING"
  | "BREAK"
  | "NEEDS_ATTENTION"
  | "HIGH_RISK"
  | "IDLE";

export interface FocusOverviewResponse {
  metricDate: string;
  totalStudyingCount: number;
  exitStudentCount: number;
  highRiskStudentCount: number;
  eventCount: number;
  protectionRate: number;
  averageReturnSeconds: number;
  policy: FocusPolicyResponse;
}

export interface FocusStudentResponse {
  studentId: string;
  studentName: string;
  studentNo: string;
  className: string | null;
  gradeName: string | null;
  status: FocusStudentStatus;
  activeSessionId: string | null;
  eventCount: number;
  returnCount: number;
  totalAwaySeconds: number;
  longestAwaySeconds: number;
  averageReturnSeconds: number;
  lastEventAt: string | null;
}

export interface FocusEventResponse {
  id: string;
  studentId: string;
  studentName: string;
  className: string | null;
  eventType: string;
  occurredAt: string;
  durationSeconds: number | null;
  studySessionId: string | null;
}

export async function getFocusOverview(date?: string) {
  const query = date ? `?date=${encodeURIComponent(date)}` : "";
  return apiFetch<FocusOverviewResponse>(`/admin/focus/overview${query}`);
}

export async function getFocusStudents(params?: {
  date?: string;
  classId?: string;
  status?: FocusStudentStatus | "ALL";
}) {
  const qs = new URLSearchParams();
  if (params?.date) qs.set("date", params.date);
  if (params?.classId) qs.set("classId", params.classId);
  if (params?.status && params.status !== "ALL") qs.set("status", params.status);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<FocusStudentResponse[]>(`/admin/focus/students${query}`);
}

export async function getFocusEvents(params?: {
  date?: string;
  studentId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.date) qs.set("date", params.date);
  if (params?.studentId) qs.set("studentId", params.studentId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<FocusEventResponse[]>(`/admin/focus/events${query}`);
}

export interface RetentionOverviewResponse {
  weeklyActiveStudents: number;
  planAchievedRate: number;
  focusEventCount: number;
  pendingGoalApprovalCount: number;
  openInterventionCount: number;
  focusRiskStudents: Array<{
    studentId: string;
    studentName: string;
    className: string | null;
    eventCount: number;
    lastEventAt: string | null;
  }>;
}

export interface RetentionInterventionResponse {
  id: string;
  studentId: string;
  studentName: string;
  className: string | null;
  reasonType:
    | "STREAK_BROKEN"
    | "TARGET_SHORTFALL"
    | "FOCUS_INTERRUPTION"
    | "MISSION_NOT_ACCEPTED";
  reasonDate: string;
  severity: "LOW" | "MEDIUM" | "HIGH";
  message: string;
  createdAt: string;
  roadmap: {
    targetName: string;
    targetDate: string;
    reminderEnabled: boolean;
    reminderTime: string;
  } | null;
  currentMission: {
    id: string;
    title: string;
    status: string;
    targetMinutes: number;
  } | null;
}

export interface RetentionGoalResponse {
  studentId: string;
  studentName: string;
  className: string | null;
  gradeName: string | null;
  targetUniversityName: string;
  tvGoalConsent: boolean;
  tvGoalApprovalStatus: "NOT_REQUESTED" | "PENDING" | "APPROVED" | "REJECTED";
  tvGoalReviewedAt: string | null;
  tvGoalReviewMemo: string | null;
  targetUniversityMedia: {
    id: string;
    publicUrl: string;
    originalName: string;
  } | null;
}

export async function getRetentionOverview() {
  return apiFetch<RetentionOverviewResponse>("/admin/retention/overview");
}

export async function getRetentionGoals() {
  return apiFetch<RetentionGoalResponse[]>("/admin/retention/goals");
}

export async function getRetentionInterventions() {
  return apiFetch<RetentionInterventionResponse[]>(
    "/admin/retention/interventions",
  );
}

export async function generateRetentionInterventions() {
  return apiFetch<RetentionInterventionResponse[]>(
    "/admin/retention/interventions/generate",
    { method: "POST" },
  );
}

export async function messageRetentionIntervention(
  interventionId: string,
  message?: string,
) {
  return apiFetch<unknown>(
    `/admin/retention/interventions/${interventionId}/message`,
    {
      method: "POST",
      body: JSON.stringify({ message }),
    },
  );
}

export async function recommendRetentionPlan(interventionId: string) {
  return apiFetch<unknown>(
    `/admin/retention/interventions/${interventionId}/recommend-plan`,
    { method: "POST" },
  );
}

export interface DailyMissionTemplateResponse {
  id: string;
  gradeId: string | null;
  classId: string | null;
  gradeName: string | null;
  className: string | null;
  title: string;
  subjectName: string;
  targetMinutes: number;
  isActive: boolean;
  sortOrder: number;
}

export interface DailyMissionOverviewResponse {
  missionDate: string;
  totalAssignedCount: number;
  completedCount: number;
  incompleteCount: number;
  completionRate: number;
  notificationOpenCount: number;
  reminderEnabledStudentCount: number;
  missions: Array<{
    id: string;
    studentId: string;
    studentName: string;
    className: string | null;
    title: string;
    subjectName: string;
    targetMinutes: number;
    status: "ASSIGNED" | "COMPLETED" | "EXPIRED";
    source: "ROADMAP" | "TEMPLATE" | "MIXED";
    completedAt: string | null;
  }>;
}

export async function getDailyMissionTemplates() {
  return apiFetch<DailyMissionTemplateResponse[]>(
    "/admin/retention/mission-templates",
  );
}

export async function createDailyMissionTemplate(
  data: Partial<DailyMissionTemplateResponse>,
) {
  return apiFetch<DailyMissionTemplateResponse>(
    "/admin/retention/mission-templates",
    { method: "POST", body: JSON.stringify(data) },
  );
}

export async function updateDailyMissionTemplate(
  templateId: string,
  data: Partial<DailyMissionTemplateResponse>,
) {
  return apiFetch<DailyMissionTemplateResponse>(
    `/admin/retention/mission-templates/${templateId}`,
    { method: "PATCH", body: JSON.stringify(data) },
  );
}

export async function getDailyMissionOverview() {
  return apiFetch<DailyMissionOverviewResponse>(
    "/admin/retention/daily-missions/overview",
  );
}

export async function reviewRetentionGoal(
  studentId: string,
  status: "APPROVED" | "REJECTED" | "PENDING",
  memo?: string,
) {
  return apiFetch<unknown>(`/admin/retention/goals/${studentId}/review`, {
    method: "POST",
    body: JSON.stringify({ status, memo }),
  });
}

// ─── Ops Command Center ──────────────────────────────

export type OpsTaskReasonType =
  | "NOT_CHECKED_IN"
  | "EARLY_LEAVE"
  | "DAILY_MISSION_INCOMPLETE"
  | "TARGET_SHORTFALL"
  | "FOCUS_INTERRUPTION";

export type OpsTaskSeverity = "LOW" | "MEDIUM" | "HIGH";
export type OpsTaskStatus = "OPEN" | "RESOLVED" | "DISMISSED";

export interface OpsOverviewResponse {
  taskDate: string;
  totalCount: number;
  openCount: number;
  resolvedCount: number;
  dismissedCount: number;
  highSeverityOpenCount: number;
  parentReportCount: number;
  completionRate: number;
}

export interface OpsTaskResponse {
  id: string;
  studentId: string;
  studentName: string;
  studentNo: string;
  className: string | null;
  gradeName: string | null;
  taskDate: string;
  reasonType: OpsTaskReasonType;
  severity: OpsTaskSeverity;
  status: OpsTaskStatus;
  message: string;
  sourceSnapshot: Record<string, unknown>;
  resolvedAt: string | null;
  createdAt: string;
  updatedAt: string;
  actions: Array<{
    id: string;
    actionType: string;
    actorName: string | null;
    payload: Record<string, unknown>;
    createdAt: string;
  }>;
  parentReports: Array<{
    id: string;
    tokenId: string;
    message: string;
    expiresAt: string;
    viewedAt: string | null;
    createdAt: string;
  }>;
}

export interface ParentReportIssueResponse {
  report: {
    id: string;
    tokenId: string;
    message: string;
    expiresAt: string;
    createdAt: string;
  };
  urlPath: string;
}

export async function getOpsOverview() {
  return apiFetch<OpsOverviewResponse>("/admin/ops/overview");
}

export async function generateOpsTasks() {
  return apiFetch<OpsTaskResponse[]>("/admin/ops/tasks/generate", {
    method: "POST",
  });
}

export async function getOpsTasks(params?: {
  status?: OpsTaskStatus;
  reasonType?: OpsTaskReasonType;
  severity?: OpsTaskSeverity;
}) {
  const qs = new URLSearchParams();
  if (params?.status) qs.set("status", params.status);
  if (params?.reasonType) qs.set("reasonType", params.reasonType);
  if (params?.severity) qs.set("severity", params.severity);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<OpsTaskResponse[]>(`/admin/ops/tasks${query}`);
}

export async function sendOpsStudentMessage(taskId: string, message?: string) {
  return apiFetch<OpsTaskResponse>(`/admin/ops/tasks/${taskId}/student-message`, {
    method: "POST",
    body: JSON.stringify({ message }),
  });
}

export async function createOpsParentReport(taskId: string, message?: string) {
  return apiFetch<ParentReportIssueResponse>(
    `/admin/ops/tasks/${taskId}/parent-report`,
    {
      method: "POST",
      body: JSON.stringify({ message }),
    },
  );
}

export async function resolveOpsTask(taskId: string) {
  return apiFetch<OpsTaskResponse>(`/admin/ops/tasks/${taskId}/resolve`, {
    method: "POST",
  });
}

export async function dismissOpsTask(taskId: string) {
  return apiFetch<OpsTaskResponse>(`/admin/ops/tasks/${taskId}/dismiss`, {
    method: "POST",
  });
}

// ─── Parent CRM ──────────────────────────────────────

export type GuardianRelation =
  | "MOTHER"
  | "FATHER"
  | "GRANDPARENT"
  | "GUARDIAN"
  | "OTHER";
export type ConsultationContactType =
  | "CALL"
  | "SMS"
  | "KAKAO"
  | "IN_PERSON"
  | "LINK"
  | "OTHER";
export type ConsultationDirection = "OUTBOUND" | "INBOUND";
export type ParentFollowUpStatus = "OPEN" | "DONE" | "DISMISSED";

export interface GuardianResponse {
  id: string;
  studentId: string;
  studentName: string;
  studentNo: string;
  className: string | null;
  gradeName: string | null;
  name: string;
  relation: GuardianRelation;
  phone: string | null;
  email: string | null;
  isPrimary: boolean;
  memo: string | null;
}

export interface ParentFollowUpResponse {
  id: string;
  studentId: string;
  studentName: string;
  studentNo: string;
  className: string | null;
  gradeName: string | null;
  guardianId: string | null;
  guardianName: string | null;
  consultationId: string | null;
  sourceOpsTaskId: string | null;
  assignedToName: string | null;
  title: string;
  dueAt: string;
  status: ParentFollowUpStatus;
  completedAt: string | null;
  createdAt: string;
}

export interface ParentConsultationResponse {
  id: string;
  studentId: string;
  studentName: string;
  studentNo: string;
  className: string | null;
  gradeName: string | null;
  guardianId: string | null;
  guardianName: string | null;
  guardianRelation: GuardianRelation | null;
  createdByName: string | null;
  contactType: ConsultationContactType;
  direction: ConsultationDirection;
  occurredAt: string;
  summary: string;
  detail: string | null;
  promisedAction: string | null;
  createdAt: string;
  followUps: Array<{
    id: string;
    title: string;
    dueAt: string;
    status: ParentFollowUpStatus;
  }>;
  latestReport: {
    id: string;
    expiresAt: string;
    viewedAt: string | null;
  } | null;
}

export interface ParentCrmOverviewResponse {
  openFollowUpCount: number;
  overdueFollowUpCount: number;
  todayFollowUpCount: number;
  guardianCount: number;
  recentConsultations: ParentConsultationResponse[];
}

export interface ParentConsultationReportIssueResponse {
  report: {
    id: string;
    tokenId: string;
    message: string;
    expiresAt: string;
    createdAt: string;
  };
  urlPath: string;
}

export async function getParentCrmOverview() {
  return apiFetch<ParentCrmOverviewResponse>("/admin/parents/overview");
}

export async function getParentGuardians(params?: {
  studentId?: string;
  keyword?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.studentId) qs.set("studentId", params.studentId);
  if (params?.keyword) qs.set("keyword", params.keyword);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<GuardianResponse[]>(`/admin/parents/guardians${query}`);
}

export async function createParentGuardian(data: {
  studentId: string;
  name: string;
  relation: GuardianRelation;
  phone?: string | null;
  email?: string | null;
  isPrimary?: boolean;
  memo?: string | null;
}) {
  return apiFetch<GuardianResponse>("/admin/parents/guardians", {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function getParentConsultations(params?: {
  studentId?: string;
  guardianId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.studentId) qs.set("studentId", params.studentId);
  if (params?.guardianId) qs.set("guardianId", params.guardianId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<ParentConsultationResponse[]>(
    `/admin/parents/consultations${query}`,
  );
}

export async function createParentConsultation(data: {
  studentId: string;
  guardianId?: string | null;
  contactType: ConsultationContactType;
  direction: ConsultationDirection;
  summary: string;
  detail?: string | null;
  promisedAction?: string | null;
  nextFollowUpAt?: string | null;
}) {
  return apiFetch<ParentConsultationResponse>(
    "/admin/parents/consultations",
    {
      method: "POST",
      body: JSON.stringify(data),
    },
  );
}

export async function getParentFollowUps(params?: {
  status?: ParentFollowUpStatus;
  studentId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.status) qs.set("status", params.status);
  if (params?.studentId) qs.set("studentId", params.studentId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<ParentFollowUpResponse[]>(
    `/admin/parents/follow-ups${query}`,
  );
}

export async function updateParentFollowUp(
  followUpId: string,
  data: { status?: ParentFollowUpStatus; dueAt?: string; title?: string },
) {
  return apiFetch<ParentFollowUpResponse>(
    `/admin/parents/follow-ups/${followUpId}`,
    { method: "PATCH", body: JSON.stringify(data) },
  );
}

export async function createParentConsultationReport(
  consultationId: string,
  message?: string,
) {
  return apiFetch<ParentConsultationReportIssueResponse>(
    `/admin/parents/consultations/${consultationId}/share-report`,
    { method: "POST", body: JSON.stringify({ message }) },
  );
}

export async function createOpsParentFollowUp(taskId: string, title?: string) {
  return apiFetch<ParentFollowUpResponse>(
    `/admin/ops/tasks/${taskId}/parent-follow-up`,
    { method: "POST", body: JSON.stringify({ title }) },
  );
}

// ─── Study Overview (Analytics) ───────────────────────

export interface StudyMetric {
  id: string;
  studentId: string;
  metricDate: string;
  attendanceMinutes: number;
  studyMinutes: number;
  breakMinutes: number;
  targetMinutes: number;
  achievedRate: string;
  pagesCompleted: number;
  problemsSolved: number;
  studySessionCount: number;
  attendanceStatus: string;
  streakDays: number;
  student: {
    id: string;
    user: { name: string };
    grade: { name: string };
    class: { name: string };
  };
}

export interface AttendanceStatsResponse {
  total: number;
  checkedIn: number;
  attendanceRate: number;
  late: number;
  earlyLeave: number;
}

export interface DirectorOverviewResponse {
  attendanceRate: number;
  seatUtilizationRate: number;
  totalStudyMinutes: number;
  activeStudentCount: number;
}

export interface RiskStudentResponse {
  studentId: string;
  studentName: string;
  className: string | null;
  riskLevel: "LOW" | "MEDIUM" | "HIGH";
  attendanceRate: number;
  averageStudyMinutes: number;
  averageAchievedRate: number;
  streakDays: number;
  recommendedTargetMinutes: number;
  recommendedFocusSubjects: string[];
  recommendedPlanTemplate: Array<{
    subjectName: string;
    title: string;
    targetMinutes: number;
  }>;
}

export interface ParentAccessResponse {
  token: string;
  expiresInDays: number;
  student: {
    id: string;
    studentNo: string;
    name: string;
    className: string | null;
  };
}

export async function getStudyOverview(params?: {
  startDate?: string;
  endDate?: string;
  classId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.startDate) qs.set("startDate", params.startDate);
  if (params?.endDate) qs.set("endDate", params.endDate);
  if (params?.classId) qs.set("classId", params.classId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<StudyMetric[]>(`/admin/study-overview${query}`);
}

export async function getAttendanceStatsApi(params?: {
  startDate?: string;
  endDate?: string;
  classId?: string;
}) {
  const qs = new URLSearchParams();
  if (params?.startDate) qs.set("startDate", params.startDate);
  if (params?.endDate) qs.set("endDate", params.endDate);
  if (params?.classId) qs.set("classId", params.classId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<AttendanceStatsResponse>(`/admin/attendance-stats${query}`);
}

export async function getDirectorOverview() {
  return apiFetch<DirectorOverviewResponse>("/director/overview");
}

export async function getRiskStudents(classId?: string) {
  const qs = new URLSearchParams();
  if (classId) qs.set("classId", classId);
  const query = qs.toString() ? `?${qs}` : "";
  return apiFetch<RiskStudentResponse[]>(
    `/admin/insights/students/risks${query}`,
  );
}

export async function issueParentAccess(
  studentId: string,
  expiresInDays: number,
) {
  return apiFetch<ParentAccessResponse>("/admin/parent-access/issue", {
    method: "POST",
    body: JSON.stringify({ studentId, expiresInDays }),
  });
}

// ─── Grades / Classes ─────────────────────────────────

export async function getGrades() {
  return apiFetch<Array<{ id: string; name: string; sortOrder: number }>>(
    "/admin/grades",
  );
}

export async function getClasses() {
  return apiFetch<
    Array<{ id: string; name: string; gradeId: string; sortOrder: number }>
  >("/admin/classes");
}
