import 'package:flutter/foundation.dart';

import '../../models/product/product.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();

  static final FavoritesStore instance = FavoritesStore._();

  final List<Product> _favorites = [];

  List<Product> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String productId) {
    return _favorites.any((product) => product.id == productId);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }

    notifyListeners();
  }

  void removeFavorite(String productId) {
    _favorites.removeWhere((product) => product.id == productId);

    notifyListeners();
  }
}
