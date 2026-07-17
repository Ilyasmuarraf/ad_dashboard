import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/campaign.dart';
import '../models/forecast_data.dart';
import '../models/anomaly.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('CRITICAL: API_BASE_URL is not set in the .env file.');
    }

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // CAMPAIGNS & CACHING

  Future<List<Campaign>> fetchCampaigns() async {
    try {
      final response = await _dio.get(AppConstants.campaignsEndpoint);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        List<Campaign> campaigns = [];

        if (data is Map<String, dynamic> && data.containsKey('campaigns')) {
          campaigns = (data['campaigns'] as List)
              .map((json) => Campaign.fromJson(json))
              .toList();
        }

        if (campaigns.isNotEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
              AppConstants.campaignsCacheKey,
              jsonEncode(data),
            );
          } catch (_) {}
          return campaigns;
        }
      }
      throw Exception('Unexpected API Response format.');
    } catch (apiError) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(AppConstants.campaignsCacheKey);

        if (cachedData != null) {
          final data = jsonDecode(cachedData);
          if (data is Map<String, dynamic> && data.containsKey('campaigns')) {
            return (data['campaigns'] as List)
                .map((json) => Campaign.fromJson(json))
                .toList();
          }
        }
      } catch (_) {}

      throw Exception(
        'Failed to load campaigns. Please check your network connection.',
      );
    }
  }

  Future<Campaign> fetchCampaignDetail(String id) async {
    try {
      final response = await _dio.get('${AppConstants.campaignsEndpoint}/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        if (data is Map<String, dynamic> && data.containsKey('campaign')) {
          return Campaign.fromJson(data['campaign']);
        }
      }
      throw Exception('Failed to load campaign details.');
    } catch (e) {
      throw Exception('Could not load campaign details. Check connection.');
    }
  }

  // FORECASTING & HISTORY
  Future<List<DailyMetric>> fetchHistory(String id) async {
    try {
      final sanitizedId = id.replaceAll('_', '');
      final response = await _dio.get('/campaigns/$sanitizedId/history');

      final rawData = response.data['data'] ?? response.data;
      final List<dynamic> dataList = rawData is List ? rawData : [];

      return dataList.map((json) => DailyMetric.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch campaign history: $e');
    }
  }

  // --- FETCH FORECAST ---
  Future<List<ForecastPoint>> fetchForecast(
    String id,
    List<DailyMetric> historyData,
  ) async {
    try {
      final sanitizedId = id.replaceAll('_', '');
      final response = await _dio.get('/campaigns/$sanitizedId/forecast');

      final rawData = response.data['data'] ?? response.data;
      final List<dynamic> dataList = rawData is List ? rawData : [];

      return dataList.map((json) => ForecastPoint.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch campaign forecast: $e');
    }
  }
  // DASHBOARD SUMMARY

  Future<Map<String, dynamic>> fetchSummary(String dateRange) async {
    try {
      final response = await _dio.get(
        '${AppConstants.summaryEndpoint}?range=$dateRange',
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        if (data is Map<String, dynamic> && data.containsKey('summary')) {
          return data['summary'];
        }
      }
      throw Exception('Failed to load summary.');
    } catch (e) {
      throw Exception('Could not load dashboard summary.');
    }
  }

  // ANOMALY DETECTION (POLLING)

  Future<Map<String, dynamic>> fetchLiveSnapshot() async {
    try {
      final response = await _dio.get('/campaigns/metrics/live');

      if (response.data is String) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.data as String) as Map<String, dynamic>;
        return decoded;
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch live snapshot: $e');
    }
  }

  Future<List<Anomaly>> detectAnomalies(Map<String, dynamic> snapshot) async {
    final List<Anomaly> detectedAnomalies = [];

    final Map<String, dynamic> cleanSnapshot = snapshot['data'] ?? snapshot;
    final rawCampaigns = cleanSnapshot['campaigns'];

    if (rawCampaigns is! List) return detectedAnomalies;

    for (final camp in rawCampaigns) {
      final String id = camp['id'] ?? 'Unknown';
      final double spendLastHour = (camp['spend_last_hour'] ?? 0).toDouble();
      final double ctrLastHour = (camp['ctr_last_hour'] ?? 0).toDouble();
      final int clicks = (camp['clicks_last_hour'] ?? 0).toInt();
      final int impressions = (camp['impressions_last_hour'] ?? 0).toInt();

      if (spendLastHour > 100) {
        double expectedSpend = spendLastHour * 0.55;
        double pctChange =
            ((spendLastHour - expectedSpend) / expectedSpend) * 100;

        detectedAnomalies.add(
          Anomaly(
            campaignId: id,
            type: 'spend_spike',
            description:
                'Hourly spend spike detected: spending reached $spendLastHour SAR inside the last hour cycle.',
            timestamp:
                cleanSnapshot['timestamp'] ?? DateTime.now().toIso8601String(),
            currentValue: spendLastHour,
            expectedValue: expectedSpend,
            percentageChange: pctChange,
          ),
        );
      }

      if (ctrLastHour < 0.05 && impressions > 0) {
        double expectedCtr = 0.055;
        double pctChange = ((ctrLastHour - expectedCtr) / expectedCtr) * 100;

        detectedAnomalies.add(
          Anomaly(
            campaignId: id,
            type: 'ctr_drop',
            description:
                'CTR dropped to ${(ctrLastHour * 100).toStringAsFixed(2)}% with $clicks clicks out of $impressions impressions.',
            timestamp:
                cleanSnapshot['timestamp'] ?? DateTime.now().toIso8601String(),
            currentValue: ctrLastHour * 100,
            expectedValue: expectedCtr * 100,
            percentageChange: pctChange,
          ),
        );
      }
    }

    return detectedAnomalies;
  }
}
