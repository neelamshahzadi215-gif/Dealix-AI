class PriceHistoryPoint {
  final DateTime date;
  final double price;

  const PriceHistoryPoint({required this.date, required this.price});
}

class PriceHistory {
  final String productId;
  final List<PriceHistoryPoint> points;

  const PriceHistory({required this.productId, required this.points});

  double? get lowestPrice {
    if (points.isEmpty) return null;

    return points.map((point) => point.price).reduce((a, b) => a < b ? a : b);
  }

  double? get highestPrice {
    if (points.isEmpty) return null;

    return points.map((point) => point.price).reduce((a, b) => a > b ? a : b);
  }
}
