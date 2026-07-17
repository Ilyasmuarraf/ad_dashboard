class AppConstants {
  static const String campaignsCacheKey = 'cached_campaign_list';
  static const String campaignsEndpoint = '/campaigns';
  static const String summaryEndpoint = '/campaigns/summary';
  static const String liveMetricsEndpoint = '/campaigns/metrics/live';
  static String historyEndpoint(String id) => '/campaigns/$id/history';
  static const String forecastEndpoint = '/forecast/ctr';
  static const String anomalyEndpoint = '/anomaly/detect';
}
