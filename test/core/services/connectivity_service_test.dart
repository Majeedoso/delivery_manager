import 'dart:async';
import 'dart:io';

import 'package:delivery_manager/core/services/connectivity_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/platform.dart';

/// The splash screen doesn't start without internet. The check asks DNS for 5
/// well-known hosts, twice; one answer is enough, and a host that never
/// answers is given up after 10 seconds, so the check itself can't hang.
void main() {
  /// Runs the check under fake time and returns its answer.
  bool? check(FakeAsync async, {Duration wait = const Duration(minutes: 5)}) {
    bool? online;
    ConnectivityService.hasInternetConnection().then((value) => online = value);
    async.elapse(wait);
    return online;
  }

  test('the first host answering is enough', () {
    fakeAsync((async) {
      ConnectivityService.lookup = online;

      expect(check(async), isTrue);
      expect(dnsLookups, ['google.com']);
    });
  });

  test('a failing host is skipped for the next one', () {
    fakeAsync((async) {
      ConnectivityService.lookup = (host) async {
        dnsLookups.add(host);
        if (host == 'microsoft.com') return [InternetAddress('20.70.246.20')];
        throw SocketException('Failed host lookup: $host');
      };

      expect(check(async), isTrue);
      expect(dnsLookups, ['google.com', 'cloudflare.com', 'microsoft.com']);
    });
  });

  test('an empty answer counts as a failure', () {
    fakeAsync((async) {
      ConnectivityService.lookup = (host) async {
        dnsLookups.add(host);
        return host == 'github.com' ? [InternetAddress('140.82.121.4')] : [];
      };

      expect(check(async), isTrue);
      expect(dnsLookups.last, 'github.com');
    });
  });

  test('all hosts failing twice means offline', () {
    fakeAsync((async) {
      ConnectivityService.lookup = offline;

      expect(check(async), isFalse);
      expect(dnsLookups, hasLength(10), reason: '5 hosts, 2 attempts');
    });
  });

  test('the second attempt waits half a second after the first', () {
    fakeAsync((async) {
      ConnectivityService.lookup = offline;

      ConnectivityService.hasInternetConnection();
      async.elapse(const Duration(milliseconds: 200)); // start-up pause
      expect(dnsLookups, hasLength(5));

      async.elapse(const Duration(milliseconds: 499));
      expect(dnsLookups, hasLength(5));
      async.elapse(const Duration(milliseconds: 1));
      expect(dnsLookups, hasLength(10));
    });
  });

  test('a host that never answers is given up after 10 seconds', () {
    fakeAsync((async) {
      ConnectivityService.lookup = (host) {
        if (host != 'google.com') return online(host);
        dnsLookups.add(host);
        return Completer<List<InternetAddress>>().future; // never answers
      };

      // 200 ms start-up pause + 10 s for google.com, then cloudflare answers
      final answer = check(async, wait: const Duration(milliseconds: 10200));

      expect(answer, isTrue);
      expect(dnsLookups, ['google.com', 'cloudflare.com']);
    });
  });
}
