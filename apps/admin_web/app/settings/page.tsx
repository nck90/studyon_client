'use client';
import { useState, useEffect } from 'react';
import {
  BadgeRuleResponse,
  FocusPolicyMode,
  FocusPolicyResponse,
  getAttendancePolicy,
  getBadgeRules,
  getFocusPolicy,
  updateBadgeRules,
  updateFocusPolicy,
} from '@/lib/api';
import { AlertCircle, Check, Download, Save, Settings, Trash2 } from 'lucide-react';
import { PageHeader } from '@/components/page-header';

function Toggle({ enabled, onChange }: { enabled: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      onClick={() => onChange(!enabled)}
      className={`relative w-11 h-6 rounded-full transition-colors ${enabled ? 'bg-primary' : 'bg-gray-200'}`}
    >
      <span
        className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow-sm transition-transform ${
          enabled ? 'translate-x-5' : 'translate-x-0.5'
        }`}
      />
    </button>
  );
}

function Section({
  title,
  description,
  children,
}: {
  title: string;
  description?: string;
  children: React.ReactNode;
}) {
  return (
    <div className="bg-white rounded-lg p-6 border border-card-border card-shadow">
      <div className="mb-5">
        <h3 className="text-[11px] font-bold text-text-tertiary tracking-wide uppercase">{title}</h3>
        {description && <p className="text-xs text-text-tertiary mt-1.5">{description}</p>}
      </div>
      {children}
    </div>
  );
}

function InputField({
  label, type = 'text', value, onChange, min, max,
}: {
  label: string; type?: string; value: string; onChange: (v: string) => void; min?: string; max?: string;
}) {
  return (
    <div>
      <label className="text-xs font-semibold text-text-secondary mb-1.5 block">{label}</label>
      <input
        type={type} value={value} onChange={e => onChange(e.target.value)} min={min} max={max}
        className="w-full rounded-xl bg-bg border border-card-border px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/30"
      />
    </div>
  );
}

function splitPackageList(value: string) {
  return value
    .split(/\r?\n|,/)
    .map(item => item.trim())
    .filter(Boolean);
}

function joinPackageList(value: unknown) {
  return Array.isArray(value) ? value.filter(item => typeof item === 'string').join('\n') : '';
}

const metricLabels: Record<BadgeRuleResponse['metric'], string> = {
  ATTENDANCE_STREAK_DAYS: '연속 출석일',
  DAILY_STUDY_MINUTES: '일간 공부 시간',
  DAILY_ACHIEVED_RATE: '일간 목표 달성률',
  WEEKLY_STUDY_MINUTES: '주간 공부 시간',
  MONTHLY_STUDY_MINUTES: '월간 공부 시간',
  PROBLEMS_SOLVED: '문제 풀이 수',
  PAGES_COMPLETED: '완료 페이지 수',
};

const modeLabels: Record<FocusPolicyMode, string> = {
  SOFT_LOCK: '소프트 락',
  ANDROID_DEVICE_OWNER: 'Android Device Owner',
  IOS_SCREEN_TIME: 'iOS Screen Time',
};

export default function SettingsPage() {
  const [roomName, setRoomName] = useState('자습실 A');
  const [totalSeats, setTotalSeats] = useState('40');
  const [openTime, setOpenTime] = useState('09:00');
  const [closeTime, setCloseTime] = useState('22:00');
  const [breakTime, setBreakTime] = useState('20');
  const [notifCheckIn, setNotifCheckIn] = useState(true);
  const [notifCheckOut, setNotifCheckOut] = useState(true);
  const [notifRanking, setNotifRanking] = useState(false);
  const [notifAlert, setNotifAlert] = useState(true);
  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const [saved, setSaved] = useState(false);
  const [policy, setPolicy] = useState<FocusPolicyResponse | null>(null);
  const [blockedPackages, setBlockedPackages] = useState('');
  const [allowedPackages, setAllowedPackages] = useState('');
  const [badgeRules, setBadgeRules] = useState<BadgeRuleResponse[]>([]);
  const [loadingOps, setLoadingOps] = useState(true);
  const [savingOps, setSavingOps] = useState(false);
  const [opsMessage, setOpsMessage] = useState<string | null>(null);
  const [opsError, setOpsError] = useState<string | null>(null);

  useEffect(() => {
    getAttendancePolicy()
      .then((data: unknown) => {
        const d = data as Record<string, unknown>;
        if (d?.lateCutoffTime) setOpenTime(String(d.lateCutoffTime).slice(0, 5));
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    Promise.all([getFocusPolicy(), getBadgeRules()])
      .then(([focusPolicy, rules]) => {
        setPolicy(focusPolicy);
        setBlockedPackages(joinPackageList(focusPolicy.blockedPackages));
        setAllowedPackages(joinPackageList(focusPolicy.allowedPackages));
        setBadgeRules(rules);
      })
      .catch(error => setOpsError(error instanceof Error ? error.message : '운영 정책을 불러오지 못했습니다.'))
      .finally(() => setLoadingOps(false));
  }, []);

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  const handleOperationalSave = async () => {
    if (!policy) return;
    setSavingOps(true);
    setOpsError(null);
    setOpsMessage(null);
    try {
      const [nextPolicy, nextRules] = await Promise.all([
        updateFocusPolicy({
          policyName: policy.policyName,
          mode: policy.mode,
          isEnabled: policy.isEnabled,
          blockedPackages: splitPackageList(blockedPackages),
          allowedPackages: splitPackageList(allowedPackages),
          graceSeconds: policy.graceSeconds,
          opsQueueThreshold: policy.opsQueueThreshold,
          parentReportThreshold: policy.parentReportThreshold,
        }),
        updateBadgeRules(
          badgeRules.map(rule => ({
            id: rule.id,
            badgeId: rule.badgeId,
            metric: rule.metric,
            threshold: rule.threshold,
            windowDays: rule.windowDays,
            isActive: rule.isActive,
          }))
        ),
      ]);
      setPolicy(nextPolicy);
      setBlockedPackages(joinPackageList(nextPolicy.blockedPackages));
      setAllowedPackages(joinPackageList(nextPolicy.allowedPackages));
      setBadgeRules(nextRules);
      setOpsMessage('운영 정책이 저장되었습니다.');
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : '운영 정책 저장에 실패했습니다.');
    } finally {
      setSavingOps(false);
    }
  };

  const updateRule = (id: string, patch: Partial<BadgeRuleResponse>) => {
    setBadgeRules(current => current.map(rule => (rule.id === id ? { ...rule, ...patch } : rule)));
  };

  return (
    <div className="p-6 md:p-8 max-w-5xl mx-auto">
      <PageHeader title="설정" description="학원 운영 환경을 설정합니다" icon={Settings} />

      <div className="space-y-4">
        <Section title="학원 정보">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <InputField label="학원 이름" value={roomName} onChange={setRoomName} />
            <InputField label="총 좌석 수" type="number" value={totalSeats} onChange={setTotalSeats} min="1" />
          </div>
        </Section>

        <Section title="운영 시간">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <InputField label="개방 시간" type="time" value={openTime} onChange={setOpenTime} />
            <InputField label="마감 시간" type="time" value={closeTime} onChange={setCloseTime} />
            <InputField label="최대 휴식 (분)" type="number" value={breakTime} onChange={setBreakTime} min="5" max="60" />
          </div>
        </Section>

        <Section title="알림 규칙">
          <div className="space-y-5">
            {[
              { label: '입실 알림', desc: '학생이 입실할 때 알림', value: notifCheckIn, set: setNotifCheckIn },
              { label: '퇴실 알림', desc: '학생이 퇴실할 때 알림', value: notifCheckOut, set: setNotifCheckOut },
              { label: '일일 랭킹 알림', desc: '매일 오후 10시 랭킹 집계 알림', value: notifRanking, set: setNotifRanking },
              { label: '이상 행동 알림', desc: '장시간 이석 등 이상 감지 시 알림', value: notifAlert, set: setNotifAlert },
            ].map(item => (
              <div key={item.label} className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold text-text-primary">{item.label}</p>
                  <p className="text-xs text-text-tertiary mt-0.5">{item.desc}</p>
                </div>
                <Toggle enabled={item.value} onChange={item.set} />
              </div>
            ))}
          </div>
        </Section>

        <Section
          title="집중모드 정책"
          description="학생 앱에서 자습 ON 상태일 때 적용할 차단 정책입니다."
        >
          {loadingOps ? (
            <div className="h-28 rounded-lg bg-bg animate-pulse" />
          ) : policy ? (
            <div className="space-y-5">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <p className="text-sm font-semibold text-text-primary">정책 활성화</p>
                  <p className="text-xs text-text-tertiary mt-0.5">비활성화하면 학생별 집중모드 설정만 저장됩니다.</p>
                </div>
                <Toggle enabled={policy.isEnabled} onChange={value => setPolicy({ ...policy, isEnabled: value })} />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <InputField
                  label="정책 이름"
                  value={policy.policyName}
                  onChange={value => setPolicy({ ...policy, policyName: value })}
                />
                <div>
                  <label className="text-xs font-semibold text-text-secondary mb-1.5 block">차단 모드</label>
                  <select
                    value={policy.mode}
                    onChange={event => setPolicy({ ...policy, mode: event.target.value as FocusPolicyMode })}
                    className="w-full rounded-xl bg-bg border border-card-border px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/30"
                  >
                    {Object.entries(modeLabels).map(([mode, label]) => (
                      <option key={mode} value={mode}>{label}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <InputField
                  label="복귀 유예초"
                  type="number"
                  min="0"
                  value={String(policy.graceSeconds)}
                  onChange={value => setPolicy({ ...policy, graceSeconds: Math.max(0, Number(value) || 0) })}
                />
                <InputField
                  label="운영 큐 기준"
                  type="number"
                  min="1"
                  value={String(policy.opsQueueThreshold)}
                  onChange={value => setPolicy({ ...policy, opsQueueThreshold: Math.max(1, Number(value) || 1) })}
                />
                <InputField
                  label="학부모 공유 기준"
                  type="number"
                  min="1"
                  value={String(policy.parentReportThreshold)}
                  onChange={value => setPolicy({ ...policy, parentReportThreshold: Math.max(1, Number(value) || 1) })}
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-text-secondary mb-1.5 block">차단 앱 패키지</label>
                  <textarea
                    value={blockedPackages}
                    onChange={event => setBlockedPackages(event.target.value)}
                    rows={5}
                    placeholder="com.instagram.android"
                    className="w-full resize-none rounded-xl bg-bg border border-card-border px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/30"
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-text-secondary mb-1.5 block">허용 앱 패키지</label>
                  <textarea
                    value={allowedPackages}
                    onChange={event => setAllowedPackages(event.target.value)}
                    rows={5}
                    placeholder="com.studyon.studyon_client"
                    className="w-full resize-none rounded-xl bg-bg border border-card-border px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/30"
                  />
                </div>
              </div>
            </div>
          ) : (
            <p className="text-sm text-hot">집중모드 정책을 표시할 수 없습니다.</p>
          )}
        </Section>

        <Section
          title="배지 지급 규칙"
          description="학생 동기부여 배지가 자동 지급되는 기준값입니다."
        >
          {loadingOps ? (
            <div className="space-y-3">
              <div className="h-16 rounded-lg bg-bg animate-pulse" />
              <div className="h-16 rounded-lg bg-bg animate-pulse" />
            </div>
          ) : (
            <div className="space-y-3">
              {badgeRules.map(rule => (
                <div key={rule.id} className="grid grid-cols-1 md:grid-cols-[1fr_180px_92px] gap-3 items-center rounded-lg border border-card-border p-4">
                  <div>
                    <p className="text-sm font-semibold text-text-primary">{rule.badge.name}</p>
                    <p className="text-xs text-text-tertiary mt-0.5">
                      {metricLabels[rule.metric]} 기준으로 자동 지급
                    </p>
                  </div>
                  <InputField
                    label="기준값"
                    type="number"
                    min="1"
                    value={String(rule.threshold)}
                    onChange={value => updateRule(rule.id, { threshold: Math.max(1, Number(value) || 1) })}
                  />
                  <div className="flex md:justify-end">
                    <Toggle enabled={rule.isActive} onChange={value => updateRule(rule.id, { isActive: value })} />
                  </div>
                </div>
              ))}
              {badgeRules.length === 0 && (
                <p className="text-sm text-text-tertiary">등록된 배지 규칙이 없습니다.</p>
              )}
            </div>
          )}
        </Section>

        {(opsMessage || opsError) && (
          <div className={`rounded-lg border px-4 py-3 flex items-center gap-2 text-sm ${
            opsError ? 'bg-hot-light border-hot/20 text-hot' : 'bg-accent/10 border-accent/20 text-accent'
          }`}>
            {opsError ? <AlertCircle size={16} /> : <Check size={16} />}
            {opsError ?? opsMessage}
          </div>
        )}

        <div className="flex justify-end">
          <button
            onClick={handleOperationalSave}
            disabled={loadingOps || savingOps || !policy}
            className="h-11 px-6 rounded-xl text-sm font-semibold gradient-primary text-white hover:opacity-90 transition-all flex items-center gap-1.5 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Save size={15} />
            {savingOps ? '저장 중' : '운영 정책 저장'}
          </button>
        </div>

        <Section title="데이터 관리">
          <div className="flex flex-wrap gap-2.5">
            <button
              onClick={() => alert('CSV 파일을 다운로드합니다.')}
              className="h-10 px-4 bg-bg text-text-secondary text-sm font-semibold rounded-xl hover:bg-gray-200 transition-colors flex items-center gap-1.5 border border-card-border"
            >
              <Download size={14} />
              CSV 내보내기
            </button>
            <button
              onClick={() => setShowResetConfirm(true)}
              className="h-10 px-4 bg-hot-light text-hot text-sm font-semibold rounded-xl hover:bg-hot/10 transition-colors flex items-center gap-1.5 border border-hot/15"
            >
              <Trash2 size={14} />
              데이터 초기화
            </button>
          </div>
        </Section>

        <div className="flex justify-end pt-2">
          <button
            onClick={handleSave}
            className={`h-11 px-8 rounded-xl text-sm font-semibold transition-all flex items-center gap-1.5 ${
              saved ? 'bg-accent text-white' : 'gradient-primary text-white hover:opacity-90'
            }`}
          >
            {saved ? '저장됨 ✓' : '설정 저장'}
          </button>
        </div>
      </div>

      {showResetConfirm && (
        <div
          className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center z-50 p-4"
          onClick={() => setShowResetConfirm(false)}
        >
          <div
            className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-sm animate-fade-in"
            onClick={e => e.stopPropagation()}
          >
            <div className="w-12 h-12 rounded-2xl bg-hot-light flex items-center justify-center mx-auto mb-4">
              <Trash2 size={22} className="text-hot" />
            </div>
            <h3 className="text-base font-bold text-text-primary text-center mb-2">데이터 초기화</h3>
            <p className="text-sm text-text-secondary text-center mb-6 leading-relaxed">
              모든 출석 기록과 공부 시간 데이터가 삭제됩니다.<br />이 작업은 되돌릴 수 없습니다.
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setShowResetConfirm(false)}
                className="flex-1 h-11 bg-bg text-text-secondary rounded-xl text-sm font-semibold hover:bg-gray-200 transition-colors border border-card-border"
              >
                취소
              </button>
              <button
                onClick={() => { alert('데이터가 초기화되었습니다.'); setShowResetConfirm(false); }}
                className="flex-1 h-11 bg-hot text-white rounded-xl text-sm font-semibold hover:bg-red-600 transition-colors"
              >
                초기화
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
