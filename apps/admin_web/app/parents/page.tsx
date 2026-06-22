"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  Check,
  Clipboard,
  HeartHandshake,
  PhoneCall,
  RefreshCw,
  Share2,
} from "lucide-react";
import { PageHeader } from "@/components/page-header";
import {
  createParentConsultation,
  createParentConsultationReport,
  createParentGuardian,
  getParentConsultations,
  getParentCrmOverview,
  getParentFollowUps,
  getParentGuardians,
  getStudents,
  updateParentFollowUp,
  type ConsultationContactType,
  type GuardianRelation,
  type GuardianResponse,
  type ParentConsultationResponse,
  type ParentCrmOverviewResponse,
  type ParentFollowUpResponse,
  type StudentResponse,
} from "@/lib/api";

const relationLabels: Record<GuardianRelation, string> = {
  MOTHER: "어머니",
  FATHER: "아버지",
  GRANDPARENT: "조부모",
  GUARDIAN: "보호자",
  OTHER: "기타",
};

const contactLabels: Record<ConsultationContactType, string> = {
  CALL: "전화",
  SMS: "문자",
  KAKAO: "카톡",
  IN_PERSON: "대면",
  LINK: "링크",
  OTHER: "기타",
};

export default function ParentsPage() {
  const [overview, setOverview] = useState<ParentCrmOverviewResponse | null>(
    null,
  );
  const [students, setStudents] = useState<StudentResponse[]>([]);
  const [guardians, setGuardians] = useState<GuardianResponse[]>([]);
  const [consultations, setConsultations] = useState<
    ParentConsultationResponse[]
  >([]);
  const [followUps, setFollowUps] = useState<ParentFollowUpResponse[]>([]);
  const [selectedStudentId, setSelectedStudentId] = useState("");
  const [guardianName, setGuardianName] = useState("");
  const [guardianPhone, setGuardianPhone] = useState("");
  const [guardianRelation, setGuardianRelation] =
    useState<GuardianRelation>("MOTHER");
  const [selectedGuardianId, setSelectedGuardianId] = useState("");
  const [contactType, setContactType] =
    useState<ConsultationContactType>("CALL");
  const [summary, setSummary] = useState("");
  const [detail, setDetail] = useState("");
  const [promisedAction, setPromisedAction] = useState("");
  const [nextFollowUpAt, setNextFollowUpAt] = useState("");
  const [message, setMessage] = useState<string | null>(null);
  const [copiedUrl, setCopiedUrl] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const reload = useCallback(async () => {
    const [nextOverview, nextStudents, nextGuardians, nextConsultations, nextFollowUps] =
      await Promise.all([
        getParentCrmOverview(),
        getStudents(),
        getParentGuardians(
          selectedStudentId ? { studentId: selectedStudentId } : undefined,
        ),
        getParentConsultations(
          selectedStudentId ? { studentId: selectedStudentId } : undefined,
        ),
        getParentFollowUps({ status: "OPEN" }),
      ]);
    setOverview(nextOverview);
    setStudents(nextStudents);
    setGuardians(nextGuardians);
    setConsultations(nextConsultations);
    setFollowUps(nextFollowUps);
  }, [selectedStudentId]);

  useEffect(() => {
    queueMicrotask(() => {
      setLoading(true);
      reload()
        .catch((error) =>
          setMessage(
            error instanceof Error
              ? error.message
              : "학부모 CRM 데이터를 불러오지 못했습니다.",
          ),
        )
        .finally(() => setLoading(false));
    });
  }, [reload]);

  const selectedStudent = useMemo(
    () => students.find((student) => student.id === selectedStudentId) ?? null,
    [selectedStudentId, students],
  );

  const createGuardian = async () => {
    if (!selectedStudentId || !guardianName.trim()) return;
    await createParentGuardian({
      studentId: selectedStudentId,
      name: guardianName,
      relation: guardianRelation,
      phone: guardianPhone || null,
      isPrimary: guardians.length === 0,
    });
    setGuardianName("");
    setGuardianPhone("");
    setMessage("보호자를 등록했습니다.");
    await reload();
  };

  const createConsultation = async () => {
    if (!selectedStudentId || !summary.trim()) return;
    await createParentConsultation({
      studentId: selectedStudentId,
      guardianId: selectedGuardianId || null,
      contactType,
      direction: "OUTBOUND",
      summary,
      detail: detail || null,
      promisedAction: promisedAction || null,
      nextFollowUpAt: nextFollowUpAt || null,
    });
    setSummary("");
    setDetail("");
    setPromisedAction("");
    setNextFollowUpAt("");
    setMessage("상담 기록을 저장했습니다.");
    await reload();
  };

  const shareConsultation = async (consultationId: string) => {
    const issued = await createParentConsultationReport(consultationId);
    const parentBase =
      process.env.NEXT_PUBLIC_PARENT_WEB_URL ?? window.location.origin;
    const url = `${parentBase.replace(/\/$/, "")}${issued.urlPath}`;
    await navigator.clipboard?.writeText(url);
    setCopiedUrl(url);
    setMessage("상담 공유 링크를 생성하고 복사했습니다.");
    await reload();
  };

  const markDone = async (followUpId: string) => {
    await updateParentFollowUp(followUpId, { status: "DONE" });
    setMessage("후속 조치를 완료했습니다.");
    await reload();
  };

  return (
    <div className="mx-auto max-w-7xl p-6 md:p-8">
      <PageHeader
        title="학부모 CRM"
        description="보호자 정보, 상담 기록, 다음 연락, 공유 리포트를 관리합니다"
        icon={HeartHandshake}
        actions={
          <button
            type="button"
            onClick={() => void reload()}
            className="inline-flex h-10 items-center gap-2 rounded-lg bg-primary px-4 text-sm font-bold text-white"
          >
            <RefreshCw size={16} />
            새로고침
          </button>
        }
      />

      <div className="mb-5 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Kpi label="오늘 연락" value={`${overview?.todayFollowUpCount ?? 0}건`} />
        <Kpi label="지연" value={`${overview?.overdueFollowUpCount ?? 0}건`} />
        <Kpi label="열린 후속" value={`${overview?.openFollowUpCount ?? 0}건`} />
        <Kpi label="보호자" value={`${overview?.guardianCount ?? 0}명`} />
      </div>

      {message && (
        <div className="mb-4 rounded-lg bg-primary-surface px-4 py-3 text-sm font-bold text-primary">
          {message}
        </div>
      )}
      {copiedUrl && (
        <div className="mb-4 flex items-center gap-2 rounded-lg border border-card-border bg-white px-4 py-3 text-xs text-text-secondary">
          <Clipboard size={15} className="text-primary" />
          <span className="truncate">{copiedUrl}</span>
        </div>
      )}

      <div className="grid gap-4 xl:grid-cols-[380px_minmax(0,1fr)_360px]">
        <section className="rounded-lg border border-card-border bg-white p-4 card-shadow">
          <h2 className="mb-3 text-base font-extrabold text-text-primary">
            학생/보호자
          </h2>
          <select
            value={selectedStudentId}
            onChange={(event) => {
              setSelectedStudentId(event.target.value);
              setSelectedGuardianId("");
            }}
            className="mb-3 h-10 w-full rounded-lg border border-card-border bg-bg px-3 text-sm font-bold"
          >
            <option value="">학생 선택</option>
            {students.map((student) => (
              <option key={student.id} value={student.id}>
                {student.user.name} · {student.studentNo}
              </option>
            ))}
          </select>
          {selectedStudent && (
            <p className="mb-3 text-xs font-bold text-text-tertiary">
              {selectedStudent.grade?.name ?? "학년 없음"} ·{" "}
              {selectedStudent.class?.name ?? "반 없음"}
            </p>
          )}

          <div className="mb-4 grid gap-2">
            {guardians.length === 0 ? (
              <Empty text="등록된 보호자가 없습니다." />
            ) : (
              guardians.map((guardian) => (
                <button
                  key={guardian.id}
                  type="button"
                  onClick={() => setSelectedGuardianId(guardian.id)}
                  className={`rounded-lg border p-3 text-left ${
                    selectedGuardianId === guardian.id
                      ? "border-primary bg-primary-surface"
                      : "border-card-border bg-white"
                  }`}
                >
                  <p className="text-sm font-extrabold text-text-primary">
                    {guardian.name}{" "}
                    <span className="text-xs text-text-tertiary">
                      {relationLabels[guardian.relation]}
                    </span>
                  </p>
                  <p className="mt-1 text-xs font-bold text-text-tertiary">
                    {guardian.phone ?? "연락처 없음"}
                  </p>
                </button>
              ))
            )}
          </div>

          <div className="grid gap-2">
            <input
              value={guardianName}
              onChange={(event) => setGuardianName(event.target.value)}
              placeholder="보호자 이름"
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            />
            <input
              value={guardianPhone}
              onChange={(event) => setGuardianPhone(event.target.value)}
              placeholder="연락처"
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            />
            <select
              value={guardianRelation}
              onChange={(event) =>
                setGuardianRelation(event.target.value as GuardianRelation)
              }
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            >
              {Object.entries(relationLabels).map(([key, label]) => (
                <option key={key} value={key}>
                  {label}
                </option>
              ))}
            </select>
            <button
              type="button"
              onClick={() => void createGuardian()}
              disabled={!selectedStudentId || !guardianName.trim()}
              className="h-10 rounded-lg bg-primary text-sm font-extrabold text-white disabled:opacity-50"
            >
              보호자 등록
            </button>
          </div>
        </section>

        <section className="rounded-lg border border-card-border bg-white p-4 card-shadow">
          <h2 className="mb-3 text-base font-extrabold text-text-primary">
            상담 기록
          </h2>
          <div className="mb-4 grid gap-2">
            <select
              value={contactType}
              onChange={(event) =>
                setContactType(event.target.value as ConsultationContactType)
              }
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            >
              {Object.entries(contactLabels).map(([key, label]) => (
                <option key={key} value={key}>
                  {label}
                </option>
              ))}
            </select>
            <input
              value={summary}
              onChange={(event) => setSummary(event.target.value)}
              placeholder="상담 요약"
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            />
            <textarea
              value={detail}
              onChange={(event) => setDetail(event.target.value)}
              placeholder="상담 상세 메모"
              rows={4}
              className="resize-none rounded-lg border border-card-border bg-bg px-3 py-2 text-sm"
            />
            <input
              value={promisedAction}
              onChange={(event) => setPromisedAction(event.target.value)}
              placeholder="약속한 후속 조치"
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            />
            <input
              type="datetime-local"
              value={nextFollowUpAt}
              onChange={(event) => setNextFollowUpAt(event.target.value)}
              className="h-10 rounded-lg border border-card-border bg-bg px-3 text-sm"
            />
            <button
              type="button"
              onClick={() => void createConsultation()}
              disabled={!selectedStudentId || !summary.trim()}
              className="h-10 rounded-lg bg-primary text-sm font-extrabold text-white disabled:opacity-50"
            >
              상담 저장
            </button>
          </div>

          {loading ? (
            <Empty text="상담 기록을 불러오는 중입니다." />
          ) : consultations.length === 0 ? (
            <Empty text="상담 기록이 없습니다." />
          ) : (
            <div className="grid gap-3">
              {consultations.map((item) => (
                <article
                  key={item.id}
                  className="rounded-lg border border-card-border p-3"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="text-sm font-extrabold text-text-primary">
                        {item.summary}
                      </p>
                      <p className="mt-1 text-xs font-bold text-text-tertiary">
                        {item.studentName} ·{" "}
                        {item.guardianName ?? "보호자 미지정"} ·{" "}
                        {contactLabels[item.contactType]}
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => void shareConsultation(item.id)}
                      className="inline-flex h-8 items-center gap-1 rounded-lg border border-card-border px-2 text-xs font-extrabold text-text-secondary"
                    >
                      <Share2 size={13} />
                      공유
                    </button>
                  </div>
                  {item.promisedAction && (
                    <p className="mt-2 text-sm font-medium text-text-secondary">
                      {item.promisedAction}
                    </p>
                  )}
                </article>
              ))}
            </div>
          )}
        </section>

        <aside className="rounded-lg border border-card-border bg-white p-4 card-shadow">
          <h2 className="mb-3 text-base font-extrabold text-text-primary">
            후속 연락 큐
          </h2>
          {followUps.length === 0 ? (
            <Empty text="열린 후속 조치가 없습니다." />
          ) : (
            <div className="grid gap-2">
              {followUps.map((item) => (
                <div
                  key={item.id}
                  className="rounded-lg border border-card-border p-3"
                >
                  <div className="flex items-start gap-2">
                    <PhoneCall size={16} className="mt-0.5 text-primary" />
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-extrabold text-text-primary">
                        {item.title}
                      </p>
                      <p className="text-xs font-bold text-text-tertiary">
                        {item.studentName} ·{" "}
                        {new Date(item.dueAt).toLocaleString("ko-KR")}
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => void markDone(item.id)}
                      className="h-8 w-8 rounded-lg bg-accent/10 text-accent"
                      title="완료"
                    >
                      <Check size={15} className="mx-auto" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </aside>
      </div>
    </div>
  );
}

function Kpi({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-card-border bg-white p-4 card-shadow">
      <p className="text-xs font-bold text-text-tertiary">{label}</p>
      <p className="mt-2 text-2xl font-extrabold text-text-primary">{value}</p>
    </div>
  );
}

function Empty({ text }: { text: string }) {
  return (
    <div className="rounded-lg border border-dashed border-card-border bg-bg p-5 text-center text-sm font-bold text-text-tertiary">
      {text}
    </div>
  );
}
