import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/campaign.dart';
import '../models/anomaly.dart';
import '../models/forecast_data.dart';

// CORE SERVICE PROVIDER
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// CAMPAIGN LIST & FILTERING
final campaignFilterProvider = StateProvider<String>((ref) => 'All');

final campaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.fetchCampaigns();
});

final filteredCampaignsProvider = Provider<AsyncValue<List<Campaign>>>((ref) {
  final filter = ref.watch(campaignFilterProvider);
  final campaignsAsync = ref.watch(campaignsProvider);

  return campaignsAsync.whenData((campaigns) {
    if (filter == 'All') return campaigns;
    return campaigns
        .where((c) => c.status.toLowerCase() == filter.toLowerCase())
        .toList();
  });
});

// CAMPAIGN DETAIL & FORECAST
final campaignHistoryProvider = FutureProvider.family<List<DailyMetric>, String>((
  ref,
  campaignId,
) async {
  final url = Uri.parse(
    'https://e5eb0d84-2b7e-4c32-98b9-233668b4e189.mock.pstmn.io/v1/campaigns/$campaignId/history',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> historyData = jsonResponse['history'] ?? [];
    return historyData.map((item) => DailyMetric.fromJson(item)).toList();
  }
  throw Exception('Failed to load history');
});

final campaignForecastProvider =
    FutureProvider.family<List<ForecastPoint>, String>((ref, campaignId) async {
      final history = await ref.read(
        campaignHistoryProvider(campaignId).future,
      );
      final historyList = history
          .map((h) => {"date": h.date, "ctr": h.ctr})
          .toList();

      final url = Uri.parse(
        'https://e5eb0d84-2b7e-4c32-98b9-233668b4e189.mock.pstmn.io/v1/forecast/ctr',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "campaign_id": campaignId,
          "history": historyList,
          "horizon_days": 7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> forecastData = jsonResponse['forecast'] ?? [];

        return forecastData
            .map((item) => ForecastPoint.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    });

// SPEND SUMMARY & DATE RANGE
final summaryDateRangeProvider = StateProvider<String>((ref) => 'Last 7 Days');
final spendSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, dateRange) async {
      try {
        return await ref.read(apiServiceProvider).fetchSummary(dateRange);
      } catch (e) {
        return {
          'total_spend': 0.0,
          'spend_by_channel': <String, dynamic>{},
          'top_campaigns': [],
        };
      }
    });

// ANOMALY POLLING STREAM
final anomalyStreamProvider = StreamProvider<List<Anomaly>>((ref) async* {
  final api = ref.read(apiServiceProvider);

  while (true) {
    try {
      final snapshot = await api.fetchLiveSnapshot();

      final anomalies = await api.detectAnomalies(snapshot);

      yield anomalies;
    } catch (e) {
      yield [];
    }
    await Future.delayed(const Duration(seconds: 30));
  }
});
