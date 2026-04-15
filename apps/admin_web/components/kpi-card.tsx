interface KpiCardProps {
  title: string;
  value: string | number;
  emoji?: string; // TossFace emoji
  change?: string; // e.g. "+3" or "-2"
  changePositive?: boolean;
}

export function KpiCard({ title, value, emoji, change, changePositive }: KpiCardProps) {
  return (
    <div className="bg-white rounded-2xl p-5">
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-semibold text-gray-400 tracking-wide">{title}</span>
        {emoji && <span className="toss-face text-lg">{emoji}</span>}
      </div>
      <p className="text-2xl font-extrabold text-gray-900 tracking-tight tabular-nums">{value}</p>
      {change && (
        <p className={`text-xs font-medium mt-1 ${changePositive ? 'text-green-500' : 'text-red-400'}`}>
          {change}
        </p>
      )}
    </div>
  );
}
