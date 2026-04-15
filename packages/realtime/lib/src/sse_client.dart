import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:studyon_core/studyon_core.dart';

import 'sse_event.dart';

class SseClient {
  SseClient({
    required String baseUrl,
    required String path,
    this.token,
    this.onEvent,
    this.onError,
  }) : _url = '$baseUrl${ApiConstants.basePath}$path';

  final String _url;
  final String? token;
  final void Function(SseEvent event)? onEvent;
  final void Function(Object error)? onError;

  StreamSubscription<dynamic>? _subscription;
  CancelToken? _cancelToken;
  bool _isConnected = false;
  int _retryCount = 0;
  static const int _maxRetryDelay = 30;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    _cancelToken = CancelToken();
    final dio = Dio();

    try {
      final response = await dio.get<ResponseBody>(
        _url,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
        cancelToken: _cancelToken,
      );

      _isConnected = true;
      _retryCount = 0;
      final stream = response.data!.stream;

      _subscription = stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        _processLine,
        onError: (error) {
          _isConnected = false;
          onError?.call(error);
          _reconnect();
        },
        onDone: () {
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      onError?.call(e);
      _reconnect();
    }
  }

  String _currentEventType = '';
  StringBuffer _dataBuffer = StringBuffer();

  void _processLine(String line) {
    if (line.startsWith('event:')) {
      _currentEventType = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      _dataBuffer.write(line.substring(5).trim());
    } else if (line.isEmpty && _currentEventType.isNotEmpty) {
      Map<String, dynamic>? data;
      final raw = _dataBuffer.toString();
      if (raw.isNotEmpty) {
        try {
          data = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {}
      }
      onEvent?.call(SseEvent(type: _currentEventType, data: data));
      _currentEventType = '';
      _dataBuffer = StringBuffer();
    }
  }

  Future<void> _reconnect() async {
    if (_cancelToken?.isCancelled ?? true) return;
    _retryCount++;
    final delay = _retryCount.clamp(1, _maxRetryDelay);
    await Future.delayed(Duration(seconds: delay));
    if (!(_cancelToken?.isCancelled ?? true)) {
      await connect();
    }
  }

  void disconnect() {
    _cancelToken?.cancel();
    _subscription?.cancel();
    _isConnected = false;
  }
}
