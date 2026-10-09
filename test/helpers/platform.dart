import 'dart:io';

import 'package:delivery_manager/core/services/connectivity_service.dart';
import 'package:delivery_manager/core/services/notification_service.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// The API the test `.env` points at. FakeBackend matches paths below it.
const testBaseUrl = 'http://test.local/api';
const testHostUrl = 'http://test.local';

/// Loads the test `.env`. Pass [env] to load exactly that instead, and call
/// `loadTestEnv()` again in tearDown to restore the default.
void loadTestEnv({String? env}) {
  dotenv.loadFromString(
    envString:
        env ??
        'BASE_URL=$testBaseUrl\n'
            'HOST_URL=$testHostUrl',
    isOptional: true,
  );
}

/// The fakes installed before the current test (see [installPlatformFakes]).
late FakePermissions permissions;
late FakeUrlLauncher urlLauncher;
late FakeClipboard clipboard;

/// Hosts the fake DNS saw, in order.
final dnsLookups = <String>[];

/// Replaces every plugin the app touches with an in-memory fake, freshly for
/// each test. flutter_test_config.dart runs it in setUp.
Future<void> installPlatformFakes() async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  PackageInfo.setMockInitialValues(
    appName: 'Delivery',
    packageName: 'website.sofistem.delivery_manager',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  PermissionHandlerPlatform.instance = permissions = FakePermissions();
  UrlLauncherPlatform.instance = urlLauncher = FakeUrlLauncher();
  clipboard = FakeClipboard()..install();

  dnsLookups.clear();
  ConnectivityService.lookup = online;

  await NotificationService.resetForTest();
  NotificationService.fetchFcmToken = () async => null;
  NotificationService.attachToFirebase = () async {};
  TokenLocalDataSource.resetForTest();
}

/// A DNS that answers every host: the phone is online.
Future<List<InternetAddress>> online(String host) async {
  dnsLookups.add(host);
  return [InternetAddress('142.250.180.14')];
}

/// A DNS that fails every host: the phone is offline.
Future<List<InternetAddress>> offline(String host) async {
  dnsLookups.add(host);
  throw SocketException('Failed host lookup: $host');
}

/// Runtime permissions on the fake phone. Everything is granted unless a test
/// says otherwise.
class FakePermissions extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  final statuses = <Permission, PermissionStatus>{};

  /// What the system dialog answers per permission; unset keeps the status.
  final dialogAnswers = <Permission, PermissionStatus>{};
  final requested = <Permission>[];
  PermissionStatus defaultStatus = PermissionStatus.granted;
  bool openedSettings = false;

  PermissionStatus statusOf(Permission permission) =>
      statuses[permission] ?? defaultStatus;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async =>
      statusOf(permission);

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async =>
      ServiceStatus.enabled;

  @override
  Future<bool> openAppSettings() async => openedSettings = true;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requested.addAll(permissions);
    return {
      for (final permission in permissions)
        permission: statuses[permission] =
            dialogAnswers[permission] ?? statusOf(permission),
    };
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async => false;
}

/// Opens nothing; remembers every URL the app asked to open.
class FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final launched = <String>[];

  /// Whether a handler exists for the URL (false: "no app can open this").
  bool canOpen = true;

  /// Thrown by [launchUrl] when set: the phone refusing the launch.
  Object? error;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => canOpen;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    if (error != null) throw error!;
    return canOpen;
  }

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    launched.add(url);
    return canOpen;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => false;
}

/// The sounds packed in the Android app (`res/raw`), by resource name.
Set<String> packedSounds() {
  final raw = Directory('android/app/src/main/res/raw');
  if (!raw.existsSync()) return {};
  return {
    for (final file in raw.listSync().whereType<File>())
      if (!file.path.endsWith('.xml'))
        file.uri.pathSegments.last.split('.').first,
  };
}

/// The system clipboard, answering the platform channel. Set [text] to what
/// the user copied (e.g. an SMS with an OTP code).
class FakeClipboard {
  String? text;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.getData':
              return text == null ? null : {'text': text};
            case 'Clipboard.setData':
              text = (call.arguments as Map)['text'] as String?;
              return null;
            case 'Clipboard.hasStrings':
              return {'value': text?.isNotEmpty ?? false};
          }
          return null;
        });
  }
}

/// Secure storage on a phone whose Android keystore is corrupted: every read,
/// write and delete throws. Counts the wipes (deleteAll) the app attempts.
class BrokenSecureStorage extends FlutterSecureStoragePlatform
    with MockPlatformInterfaceMixin {
  int wipes = 0;

  Never _fail() => throw PlatformException(
    code: 'Exception encountered',
    message: 'javax.crypto.BadPaddingException',
  );

  /// Puts this broken storage in place for the current test.
  void install() => FlutterSecureStoragePlatform.instance = this;

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async => _fail();

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _fail();

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _fail();

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async => _fail();

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => _fail();

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    wipes++;
  }
}
