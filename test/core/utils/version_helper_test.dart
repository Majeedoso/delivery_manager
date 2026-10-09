import 'package:delivery_manager/core/utils/version_helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// The force-update prompt (backend app_versions.minimum_version) relies on these rules.
void main() {
  group('VersionHelper.compareVersions', () {
    test('orders versions numerically, not alphabetically', () {
      expect(VersionHelper.compareVersions('1.0.10', '1.0.9'), 1);
      expect(VersionHelper.compareVersions('1.10.0', '1.9.9'), 1);
      expect(VersionHelper.compareVersions('2.0.0', '10.0.0'), -1);
    });

    test('treats missing parts as zero', () {
      expect(VersionHelper.compareVersions('1.2', '1.2.0'), 0);
      expect(VersionHelper.compareVersions('1', '1.0.1'), -1);
    });
  });

  group('VersionHelper.isVersionSupported', () {
    test('accepts the minimum version and anything newer', () {
      expect(VersionHelper.isVersionSupported('1.0.0', '1.0.0'), isTrue);
      expect(VersionHelper.isVersionSupported('1.0.1', '1.0.0'), isTrue);
      expect(VersionHelper.isVersionSupported('2.0.0', '1.9.9'), isTrue);
    });

    test('rejects older versions so the update prompt is shown', () {
      expect(VersionHelper.isVersionSupported('0.9.9', '1.0.0'), isFalse);
      expect(VersionHelper.isVersionSupported('1.0.9', '1.0.10'), isFalse);
    });
  });
}
