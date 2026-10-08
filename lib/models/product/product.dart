class Product {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String category;
  final String imageUrl;
  final String barcode;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.category,
    required this.imageUrl,
    this.barcode = '',
    this.price = 0,
    this.currency = 'PKR',
    this.rating = 0,
    this.reviewCount = 0,
    this.isAvailable = true,
  });
}