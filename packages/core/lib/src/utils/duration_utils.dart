extension StudyonDurationUtils on Duration {
  /// 분 단위 값을 "Xh Ym" 형식으로 변환
  String toHoursMinutes() {
    final h = inHours;
    final m = inMinutes.remainder(60);
    if (h == 0) return '${m}분';
    if (m == 0) return '${h}시간';
    return '${h}시간 ${m}분';
  }

  /// "HH:MM:SS" 타이머 형식
  String toTimerString() {
    final h = inHours.toString().padLeft(2, '0');
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

extension MinutesToDuration on int {
  Duration get minutes => Duration(minutes: this);
}
