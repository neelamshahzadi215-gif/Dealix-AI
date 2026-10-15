import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dealix_ai/models/product/product.dart';


class RecentSearchService {
  static const String _storageKey = 'recent_searches';

  Future<List<Product>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();

    final storedItems = prefs.getStringList(_storageKey) ?? [];

    return storedItems.map((item) {
      final json = jsonDecode(item) as Map<String, dynamic>;

      return Product(
        id: json['id'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        category: json['category'] as String,
        imageUrl: json['imageUrl'] as String,
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        isAvailable: json['isAvailable'] as bool,
      );
    }).toList();
  }

  Future<void> addRecentSearch(Product product) async {
    final prefs = await SharedPreferences.getInstance();

    final currentSearches = await getRecentSearches();

    // Same product duplicate nahi hoga.
    // Agar already exist karta hai to pehle remove hoga,
    // phir top par add hoga.
    currentSearches.removeWhere(
      (item) => item.id == product.id,
    );

    currentSearches.insert(0, product);

    final limitedSearches = currentSearches.take(20).toList();

    final encodedItems = limitedSearches.map((item) {
      return jsonEncode({
        'id': item.id,
        'name': item.name,
        'brand': item.brand,
        'model': item.model,
        'category': item.category,
        'imageUrl': item.imageUrl,
        'price': item.price,
        'currency': item.currency,
        'rating': item.rating,
        'reviewCount': item.reviewCount,
        'isAvailable': item.isAvailable,
      });
    }).toList();

    await prefs.setStringList(_storageKey, encodedItems);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }
}
