"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dateOnly = dateOnly;
exports.startOfDay = startOfDay;
exports.endOfDay = endOfDay;
exports.diffMinutes = diffMinutes;
exports.weekStart = weekStart;
exports.monthKey = monthKey;
function dateOnly(input) {
    const base = input ? new Date(input) : new Date();
    return new Date(Date.UTC(base.getFullYear(), base.getMonth(), base.getDate()));
}
function startOfDay(input) {
    const base = input ? new Date(input) : new Date();
    return new Date(base.getFullYear(), base.getMonth(), base.getDate(), 0, 0, 0, 0);
}
function endOfDay(input) {
    const base = input ? new Date(input) : new Date();
    return new Date(base.getFullYear(), base.getMonth(), base.getDate(), 23, 59, 59, 999);
}
function diffMinutes(start, end) {
    if (!start || !end) {
        return 0;
    }
    return Math.max(0, Math.floor((end.getTime() - start.getTime()) / 60000));
}
function weekStart(input) {
    const base = input ? new Date(input) : new Date();
    const day = base.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    const monday = new Date(base);
    monday.setDate(base.getDate() + diff);
    return startOfDay(monday);
}
function monthKey(input) {
    const base = input ? new Date(input) : new Date();
    return `${base.getFullYear()}-${String(base.getMonth() + 1).padStart(2, '0')}`;
}
//# sourceMappingURL=date.util.js.map