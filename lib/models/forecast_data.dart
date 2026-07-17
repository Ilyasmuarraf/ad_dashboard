class DailyMetric {
  final String date;
  final int impressions;
  final int clicks;
  final double ctr;

  DailyMetric({
    required this.date,
    required this.impressions,
    required this.clicks,
    required this.ctr,
  });

  factory DailyMetric.fromJson(Map<String, dynamic> json) {
    return DailyMetric(
      date: json['date']?.toString() ?? '',
      impressions: int.tryParse(json['impressions']?.toString() ?? '0') ?? 0,
      clicks: int.tryParse(json['clicks']?.toString() ?? '0') ?? 0,
      ctr: (json['ctr'] ?? 0.0).toDouble(),
    );
  }
}

class ForecastPoint {
  final String date;
  final double expectedCtr;
  final double lowerBound;
  final double upperBound;

  ForecastPoint({
    required this.date,
    required this.expectedCtr,
    required this.lowerBound,
    required this.upperBound,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      date: json['date']?.toString() ?? '',
      expectedCtr: (json['predicted_ctr'] ?? 0.0).toDouble(),
      lowerBound: (json['lower_bound'] ?? 0.0).toDouble(),
      upperBound: (json['upper_bound'] ?? 0.0).toDouble(),
    );
  }
}
