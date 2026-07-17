import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/campaign.dart';
import '../../providers/providers.dart';
import '../../core/theme.dart';
import '../widgets/forecast_chart.dart';

class CampaignDetailScreen extends ConsumerWidget {
  final Campaign campaign;

  const CampaignDetailScreen({super.key, required this.campaign});

  String _formatNumber(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  String _formatCurrency(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(campaignHistoryProvider(campaign.id));
    final forecastAsync = ref.watch(campaignForecastProvider(campaign.id));

    final double calculatedCtr = campaign.impressions > 0
        ? (campaign.clicks / campaign.impressions) * 100
        : 0.0;
    final bool isActive = campaign.status.toLowerCase() == 'active';
    final Color statusColor = isActive
        ? AppTheme.statusActive
        : const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: '${campaign.id}-icon',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: '${campaign.id}-title',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        campaign.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        campaign.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          campaign.objective,
                          style: const TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    Icons.visibility_outlined,
                    _formatNumber(campaign.impressions),
                    'Impressions',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    Icons.ads_click,
                    _formatNumber(campaign.clicks),
                    'Clicks',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    Icons.trending_up,
                    '${calculatedCtr.toStringAsFixed(2)}%',
                    'CTR',
                    hasInfo: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    Icons.account_balance_wallet_outlined,
                    '${_formatCurrency(campaign.totalSpend)} SAR',
                    'Total spend',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'CTR Performance & Forecast',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.textSecondary,
                            size: 14,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF2C2C2C)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '30 Days',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppTheme.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CTR (%)',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChartLegend(AppTheme.primaryTeal, 'Historical CTR'),
                      const SizedBox(width: 16),
                      _buildChartLegend(
                        AppTheme.primaryTeal.withOpacity(0.5),
                        'Forecast CTR',
                        isDashed: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: historyAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      error: (err, __) => const Center(
                        child: Text(
                          'Data error',
                          style: TextStyle(color: AppTheme.alertSpike),
                        ),
                      ),
                      data: (historyData) {
                        return forecastAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          error: (err, __) => const Center(
                            child: Text(
                              'Data error',
                              style: TextStyle(color: AppTheme.alertSpike),
                            ),
                          ),
                          data: (forecastData) => ForecastChart(
                            history: historyData,
                            forecast: forecastData,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF132A22), // Dark green hue
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Recommendation',
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'CTR is predicted to increase by 12% ↗',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Consider increasing budget to maximize results',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A382D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(
                          color: AppTheme.primaryTeal.withOpacity(0.5),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(
    IconData icon,
    String value,
    String label, {
    bool hasInfo = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryTeal),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
              if (hasInfo) ...[
                const SizedBox(width: 2),
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.textSecondary,
                  size: 10,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label, {bool isDashed = false}) {
    return Row(
      children: [
        Container(width: 16, height: 2, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
