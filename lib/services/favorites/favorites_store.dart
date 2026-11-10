import 'package:flutter/material.dart';
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
    final previousLength = _favorites.length;

    _favorites.removeWhere((item) => item.id == productId);

    if (_favorites.length != previousLength) {
      notifyListeners();
    }
  }
}
