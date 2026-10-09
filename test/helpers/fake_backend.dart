import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' as test;

import 'platform.dart';

/// The backend, played by a script: a Dio transport that answers from replies
/// the test sets up and remembers every request, so data sources run on a real
/// Dio with real JSON (what swimboss does with its in-memory database).
///
/// Paths are matched below [testBaseUrl], e.g. `backend.reply('GET',
/// '/operator/orders', body: ok({...}))`. A request nothing was
/// scripted for answers 404 and fails the test in tearDown, so a wrong path
/// never passes quietly.
class FakeBackend implements HttpClientAdapter {
  FakeBackend() {
    test.addTearDown(() {
      if (unscripted.isNotEmpty) {
        test.fail(
          'FakeBackend: nothing was scripted for ${unscripted.join(', ')}',
        );
      }
    });
  }

  /// Every request, oldest first.
  final requests = <RecordedRequest>[];

  /// Requests that had no scripted reply ("GET /path").
  final unscripted = <String>[];

  final _scripts = <String, List<_Reply>>{};

  /// Answers `METHOD path` with [status] and [body] (a map or list is sent as
  /// JSON, a string as-is, e.g. an HTML error page).
  void reply(
    String method,
    String path, {
    int status = 200,
    Object? body,
    String? contentType,
  }) => _scripts['$method $path'] = [
    _Reply(status: status, body: body, contentType: contentType),
  ];

  /// Answers successive calls with [statuses]/[bodies] in turn; the last
  /// answer repeats (for retries and polling).
  void replyInTurn(String method, String path, List<FakeReply> replies) =>
      _scripts['$method $path'] = [
        for (final r in replies)
          _Reply(status: r.status, body: r.body, error: r.error),
      ];

  /// Fails `METHOD path` like the network would: a timeout, no connection...
  void fail(String method, String path, DioExceptionType type) =>
      _scripts['$method $path'] = [_Reply(error: type)];

  /// Never answers `METHOD path` (for timeouts under fake_async).
  void hang(String method, String path) =>
      _scripts['$method $path'] = [_Reply(hang: true)];

  /// The last request to `METHOD path`.
  RecordedRequest last(String method, String path) => requests.lastWhere(
    (r) => r.method == method && r.path == path,
    orElse: () => throw StateError(
      'No $method $path request; saw ${requests.join(', ')}',
    ),
  );

  /// How many requests went to `METHOD path`.
  int count(String method, String path) =>
      requests.where((r) => r.method == method && r.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // A form (a photo) is read through, as a server does: the file it streams
    // is then closed again (Windows cannot delete a file still open).
    if (options.data is FormData) await requestStream?.drain<void>();
    final path = _pathOf(options.uri);
    requests.add(
      RecordedRequest(
        method: options.method,
        path: path,
        query: Map<String, dynamic>.of(options.queryParameters),
        headers: Map<String, dynamic>.of(options.headers),
        data: options.data,
      ),
    );

    final key = '${options.method} $path';
    final script = _scripts[key];
    if (script == null) {
      unscripted.add(key);
      return _json(404, {'message': 'FakeBackend: nothing scripted for $key'});
    }
    final reply = script.length > 1 ? script.removeAt(0) : script.first;
    if (reply.hang) return Completer<ResponseBody>().future;
    if (reply.error != null) {
      throw DioException(
        requestOptions: options,
        type: reply.error!,
        error: 'FakeBackend: ${reply.error!.name}',
      );
    }
    final body = reply.body;
    if (body is String) {
      return ResponseBody.fromString(
        body,
        reply.status,
        headers: {
          Headers.contentTypeHeader: [reply.contentType ?? 'text/html'],
        },
      );
    }
    return _json(reply.status, body);
  }

  ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  String _pathOf(Uri uri) {
    final base = Uri.parse(testBaseUrl).path; // "/api"
    final path = uri.path;
    return path.startsWith('$base/') ? path.substring(base.length) : path;
  }

  @override
  void close({bool force = false}) {}
}

/// One answer in [FakeBackend.replyInTurn]: a status and body, or a failure.
class FakeReply {
  const FakeReply(this.status, [this.body]) : error = null;
  const FakeReply.failure(DioExceptionType this.error)
    : status = 0,
      body = null;

  final int status;
  final Object? body;
  final DioExceptionType? error;
}

class _Reply {
  _Reply({
    this.status = 200,
    this.body,
    this.contentType,
    this.error,
    this.hang = false,
  });

  final int status;
  final Object? body;
  final String? contentType;
  final DioExceptionType? error;
  final bool hang;
}

/// A request the app sent, as the backend received it.
class RecordedRequest {
  RecordedRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.headers,
    required this.data,
  });

  final String method;

  /// Below [testBaseUrl], e.g. `/operator/orders`.
  final String path;
  final Map<String, dynamic> query;
  final Map<String, dynamic> headers;

  /// The body as the app built it (usually a map).
  final Object? data;

  Map<String, dynamic> get json => data as Map<String, dynamic>;

  @override
  String toString() => '$method $path';
}

/// A Dio configured like the app's (base URL, JSON headers) whose transport
/// is [backend].
Dio testDio(FakeBackend backend, {List<Interceptor> interceptors = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: testBaseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.httpClientAdapter = backend;
  dio.interceptors.addAll(interceptors);
  return dio;
}
