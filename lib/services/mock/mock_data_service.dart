import '../../models/product/product.dart';
import '../../models/store/store_offer.dart';
import '../../models/history/price_history.dart';
import '../../models/alert/price_alert.dart';
import '../../models/user/user_profile.dart';

class MockDataService {
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return const [
      Product(
        id: 'p1',
        name: 'Samsung Galaxy A55 5G',
        brand: 'Samsung',
        model: 'A55 5G',
        category: 'Smartphone',
        imageUrl: '',
        barcode: '8806094881234',
        price: 124999,
        currency: 'PKR',
        rating: 4.5,
        reviewCount: 128,
        isAvailable: true,
      ),
      Product(
        id: 'p2',
        name: 'Apple AirPods Pro 2',
        brand: 'Apple',
        model: 'AirPods Pro 2',
        category: 'Audio',
        imageUrl: '',
        barcode: '194253765432',
        price: 64999,
        currency: 'PKR',
        rating: 4.7,
        reviewCount: 95,
        isAvailable: true,
      ),
      Product(
        id: 'p3',
        name: 'Dell Inspiron 15',
        brand: 'Dell',
        model: 'Inspiron 15',
        category: 'Laptop',
        imageUrl: '',
        barcode: '884116456789',
        price: 159999,
        currency: 'PKR',
        rating: 4.3,
        reviewCount: 76,
        isAvailable: true,
      ),
    ];
  }

  Future<List<StoreOffer>> getStoreOffers(String productId) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      StoreOffer(
        id: 'offer1',
        productId: productId,
        storeName: 'Daraz',
        storeUrl: 'https://www.daraz.pk/',
        price: 124999,
        currency: 'PKR',
        isAvailable: true,
        rating: 4.4,
        reviewCount: 120,
        deliveryFee: 0,
      ),
      StoreOffer(
        id: 'offer2',
        productId: productId,
        storeName: 'PriceOye',
        storeUrl: 'https://priceoye.pk/',
        price: 121999,
        currency: 'PKR',
        isAvailable: true,
        rating: 4.5,
        reviewCount: 98,
        deliveryFee: 250,
      ),
      StoreOffer(
        id: 'offer3',
        productId: productId,
        storeName: 'Telemart',
        storeUrl: 'https://www.telemart.pk/',
        price: 126499,
        currency: 'PKR',
        isAvailable: true,
        rating: 4.2,
        reviewCount: 70,
        deliveryFee: 0,
      ),
    ];
  }

  Future<PriceHistory> getPriceHistory(String productId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();

    return PriceHistory(
      productId: productId,
      points: [
        PriceHistoryPoint(
          date: now.subtract(const Duration(days: 30)),
          price: 132999,
        ),
        PriceHistoryPoint(
          date: now.subtract(const Duration(days: 20)),
          price: 129999,
        ),
        PriceHistoryPoint(
          date: now.subtract(const Duration(days: 10)),
          price: 127999,
        ),
        PriceHistoryPoint(
          date: now.subtract(const Duration(days: 5)),
          price: 125999,
        ),
        PriceHistoryPoint(
          date: now,
          price: 124999,
        ),
      ],
    );
  }

  Future<List<PriceAlert>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      PriceAlert(
        id: 'alert1',
        productId: 'p1',
        productName: 'Samsung Galaxy A55 5G',
        currentPrice: 124999,
        targetPrice: 115000,
        isEnabled: true,
      ),
    ];
  }

  Future<UserProfile> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const UserProfile(
      id: 'user1',
      name: 'Dealix User',
      email: 'user@example.com',
      city: 'Bahawalpur',
      currency: 'PKR',
    );
  }
}