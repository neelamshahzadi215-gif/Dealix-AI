class StoreOffer {
  final String id;
  final String productId;
  final String storeName;
  final String storeUrl;
  final double price;
  final String currency;
  final bool isAvailable;
  final double? rating;
  final int? reviewCount;
  final double? deliveryFee;

  const StoreOffer({
    required this.id,
    required this.productId,
    required this.storeName,
    required this.storeUrl,
    required this.price,
    this.currency = 'PKR',
    this.isAvailable = true,
    this.rating,
    this.reviewCount,
    this.deliveryFee,
  });

  double get totalPrice {
    return price + (deliveryFee ?? 0);
  }
}
