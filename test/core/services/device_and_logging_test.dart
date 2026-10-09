import 'package:delivery_manager/core/services/device_info_service.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

/// Two small services every screen relies on: the device id sent with
/// registration and login, and the logger, which must never fail the code
/// that logs.
void main() {
  group('DeviceInfoService', () {
    test('a device id read once is served from storage', () async {
      FlutterSecureStorage.setMockInitialValues({
        'cached_device_id': 'samsung/a14:14/UP1A',
      });

      final id = await DeviceInfoService(
        const FlutterSecureStorage(),
      ).getDeviceId();

      expect(id, 'samsung/a14:14/UP1A');
    });

    test('off a phone there is no id, and nothing is stored', () async {
      const storage = FlutterSecureStorage();

      expect(await DeviceInfoService(storage).getDeviceId(), isNull);
      expect(await storage.read(key: 'cached_device_id'), isNull);
    });
  });

  group('LoggingService', () {
    late List<String> printed;
    late LoggingService logging;

    setUp(() {
      printed = [];
      logging = LoggingService(
        logger: Logger(
          level: Level.trace,
          printer: SimplePrinter(colors: false),
          output: _Collect(printed),
        ),
        isDebugMode: false,
      );
    });

    test('every level reaches the log', () {
      logging.debug('debug line');
      logging.info('info line');
      logging.warning('warning line');
      logging.error('error line');

      expect(
        printed.join('\n'),
        allOf([
          contains('debug line'),
          contains('info line'),
          contains('warning line'),
          contains('error line'),
        ]),
      );
    });

    test('never throws, even with no Firebase to report to', () async {
      expect(
        () => logging.error('boom', error: StateError('x')),
        returnsNormally,
      );
      expect(() => logging.fatal('fatal'), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });
  });
}

class _Collect extends LogOutput {
  _Collect(this.lines);

  final List<String> lines;

  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}
