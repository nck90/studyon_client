interface KpiCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon?: string;
  trend?: number; // positive = up, negative = down, 0 = neutral
  color?: 'primary' | 'accent' | 'warm' | 'hot' | 'default';
}

const COLOR_MAP = {
  primary: {
    bg: 'bg-primary-surface',
    icon: 'bg-primary/10 text-primary',
    value: 'text-primary',
  },
  accent: {
    bg: 'bg-accent-light',
    icon: 'bg-accent/10 text-accent',
    value: 'text-accent',
  },
  warm: {
    bg: 'bg-warm-light',
    icon: 'bg-warm/10 text-warm',
    value: 'text-warm',
  },
  hot: {
    bg: 'bg-hot-light',
    icon: 'bg-hot/10 text-hot',
    value: 'text-hot',
  },
  default: {
    bg: 'bg-white',
    icon: 'bg-gray-100 text-gray-600',
    value: 'text-gray-900',
  },
};

export function KpiCard({
  title,
  value,
  subtitle,
  icon,
  trend,
  color = 'default',
}: KpiCardProps) {
  const colors = COLOR_MAP[color];

  return (
    <div className={`rounded-2xl p-5 shadow-sm border border-gray-100 ${colors.bg}`}>
      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          <p className="text-xs font-medium text-gray-500 mb-1">{title}</p>
          <p className={`text-2xl font-bold ${colors.value} leading-none`}>
            {value}
          </p>
          {subtitle && (
            <p className="text-xs text-gray-500 mt-1.5">{subtitle}</p>
          )}
        </div>
        {icon && (
          <div className={`w-10 h-10 rounded-xl flex items-center justify-center text-lg shrink-0 ${colors.icon}`}>
            {icon}
          </div>
        )}
      </div>

      {trend !== undefined && (
        <div className="mt-3 flex items-center gap-1">
          <span
            className={[
              'text-xs font-medium',
              trend > 0 ? 'text-accent' : trend < 0 ? 'text-hot' : 'text-gray-400',
            ].join(' ')}
          >
            {trend > 0 ? '▲' : trend < 0 ? '▼' : '─'}
            {trend !== 0 && ` ${Math.abs(trend)}%`}
          </span>
          <span className="text-xs text-gray-400">전일 대비</span>
        </div>
      )}
    </div>
  );
}
