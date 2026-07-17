class Anomaly {
  final String campaignId;
  final String type;
  final String description;
  final String timestamp;

  final double currentValue;
  final double expectedValue;
  final double percentageChange;

  Anomaly({
    required this.campaignId,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.currentValue,
    required this.expectedValue,
    required this.percentageChange,
  });

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    return Anomaly(
      campaignId: json['campaign_id'] ?? '',
      type: json['type'] ?? 'unknown',
      description: json['description'] ?? 'Anomaly detected',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      expectedValue: (json['expected_value'] ?? 0).toDouble(),
      percentageChange: (json['percentage_change'] ?? 0).toDouble(),
    );
  }
}
