export function dateOnly(input?: string | Date): Date {
  const base = input ? new Date(input) : new Date();
  return new Date(
    Date.UTC(base.getFullYear(), base.getMonth(), base.getDate()),
  );
}

export function startOfDay(input?: string | Date): Date {
  const base = input ? new Date(input) : new Date();
  return new Date(
    base.getFullYear(),
    base.getMonth(),
    base.getDate(),
    0,
    0,
    0,
    0,
  );
}

export function endOfDay(input?: string | Date): Date {
  const base = input ? new Date(input) : new Date();
  return new Date(
    base.getFullYear(),
    base.getMonth(),
    base.getDate(),
    23,
    59,
    59,
    999,
  );
}

export function diffMinutes(start?: Date | null, end?: Date | null): number {
  if (!start || !end) {
    return 0;
  }
  return Math.max(0, Math.floor((end.getTime() - start.getTime()) / 60000));
}

export function weekStart(input?: string | Date): Date {
  const base = input ? new Date(input) : new Date();
  const day = base.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  const monday = new Date(base);
  monday.setDate(base.getDate() + diff);
  return startOfDay(monday);
}

export function monthKey(input?: string | Date): string {
  const base = input ? new Date(input) : new Date();
  return `${base.getFullYear()}-${String(base.getMonth() + 1).padStart(2, '0')}`;
}
