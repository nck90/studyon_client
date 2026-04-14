class SseEvent {
  const SseEvent({
    required this.type,
    this.data,
  });

  final String type;
  final Map<String, dynamic>? data;

  @override
  String toString() => 'SseEvent($type, $data)';
}
