class PriceAlert {
  final String id;
  final String productId;
  final String productName;
  final double currentPrice;
  final double targetPrice;
  final bool isEnabled;

  const PriceAlert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.currentPrice,
    required this.targetPrice,
    this.isEnabled = true,
  });
}
