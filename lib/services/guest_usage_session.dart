import 'package:flutter/foundation.dart';

class GuestUsageSession extends ChangeNotifier {
  GuestUsageSession._();

  static final GuestUsageSession instance = GuestUsageSession._();
  static const int searchLimit = 2;

  bool _isGuest = false;
  int _usedSearches = 0;

  bool get isGuest => _isGuest;
  int get usedSearches => _usedSearches;
  int get remainingSearches => searchLimit - _usedSearches;

  void startGuestSession() {
    _isGuest = true;
    _usedSearches = 0;
    notifyListeners();
  }

  void endGuestSession() {
    _isGuest = false;
    _usedSearches = 0;
    notifyListeners();
  }

  bool tryUseSearch() {
    if (!_isGuest) return true;
    if (_usedSearches >= searchLimit) return false;

    _usedSearches++;
    notifyListeners();
    return true;
  }
}
