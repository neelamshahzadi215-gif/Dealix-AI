import 'package:flutter_test/flutter_test.dart';

import 'package:dealix_ai/services/guest_usage_session.dart';

void main() {
  final session = GuestUsageSession.instance;

  setUp(() {
    session.endGuestSession();
  });

  test('guest session allows exactly two searches', () {
    session.startGuestSession();

    expect(session.tryUseSearch(), isTrue);
    expect(session.usedSearches, 1);
    expect(session.remainingSearches, 1);

    expect(session.tryUseSearch(), isTrue);
    expect(session.usedSearches, 2);
    expect(session.remainingSearches, 0);

    expect(session.tryUseSearch(), isFalse);
    expect(session.usedSearches, 2);
  });

  test('searches are not limited outside guest mode', () {
    expect(session.tryUseSearch(), isTrue);
    expect(session.usedSearches, 0);
  });
}
