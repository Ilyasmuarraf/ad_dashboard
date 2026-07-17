class Campaign {
  final String id;
  final String name;
  final String status;
  final int impressions;
  final int clicks;
  final double totalSpend;
  final double budget;
  final String objective;
  final String startDate;
  final String audience;

  Campaign({
    required this.id,
    required this.name,
    required this.status,
    required this.impressions,
    required this.clicks,
    required this.totalSpend,
    required this.budget,
    required this.objective,
    required this.startDate,
    required this.audience,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(
            val.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;
    }

    return Campaign(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Campaign',
      status: json['status']?.toString() ?? 'Inactive',
      impressions: int.tryParse(json['impressions']?.toString() ?? '0') ?? 0,
      clicks: int.tryParse(json['clicks']?.toString() ?? '0') ?? 0,

      totalSpend: parseDouble(
        json['total_spend'] ?? json['totalSpend'] ?? json['spend'],
      ),
      budget: parseDouble(json['budget'] ?? json['total_budget'] ?? 10000.0),

      objective:
          json['objective']?.toString() ??
          json['type']?.toString() ??
          'Campaign',
      startDate:
          json['start_date']?.toString() ??
          json['startDate']?.toString() ??
          'N/A',
      audience:
          json['audience']?.toString() ??
          json['target']?.toString() ??
          'All Users',
    );
  }
}
