import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/anomaly.dart';
import '../../core/theme.dart';

class AnomalyAlertsScreen extends ConsumerWidget {
  const AnomalyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(anomalyStreamProvider);
    final campaignsList = ref.watch(campaignsProvider).value;

    final Map<String, String> nameLookupTable = {};
    if (campaignsList != null) {
      for (final c in campaignsList) {
        nameLookupTable[c.id] = c.name;
        nameLookupTable[c.id.replaceAll('_', '')] = c.name;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.menu, color: AppTheme.textPrimary),
        title: const Text(
          'Anomaly Alerts',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C2C2C)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cast_connected,
                    color: AppTheme.primaryTeal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring in real-time',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Polling Ads API every 30 seconds',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: AppTheme.statusActive),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: AppTheme.statusActive,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Recent Anomalies',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: alertsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              ),
              error: (err, stack) => const Center(
                child: Text(
                  'Failed to load alerts.',
                  style: TextStyle(color: AppTheme.alertSpike),
                ),
              ),
              data: (anomalies) {
                if (anomalies.isEmpty) {
                  return const Center(
                    child: Text(
                      'No anomalies detected.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: anomalies.length,
                  itemBuilder: (context, index) {
                    final anomaly = anomalies[index];
                    final sanitizedId = anomaly.campaignId.replaceAll('_', '');
                    final resolvedName =
                        nameLookupTable[anomaly.campaignId] ??
                        nameLookupTable[sanitizedId] ??
                        anomaly.campaignId;

                    final String timeAgo = index == 0
                        ? '2m ago'
                        : index == 1
                        ? '5m ago'
                        : '10m ago';

                    return _buildAnomalyCard(anomaly, resolvedName, timeAgo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyCard(
    Anomaly anomaly,
    String campaignName,
    String timeAgo,
  ) {
    final bool isSpike = anomaly.type == 'spend_spike';

    final Color themeColor = isSpike
        ? AppTheme.alertSpike
        : const Color(0xFFEAB308);
    final IconData mainIcon = isSpike ? Icons.trending_up : Icons.trending_down;
    final String typeLabel = isSpike ? 'Spend Spike' : 'CTR Drop';

    final String currentStr = isSpike
        ? '${anomaly.currentValue.toInt()} SAR'
        : '${anomaly.currentValue.toStringAsFixed(2)}%';
    final String expectedStr = isSpike
        ? '${anomaly.expectedValue.toInt()} SAR'
        : '${anomaly.expectedValue.toStringAsFixed(2)}%';
    final String sign = anomaly.percentageChange > 0 ? '+' : '';
    final String changeStr =
        '$sign${anomaly.percentageChange.toStringAsFixed(0)}%';

    final String description = isSpike
        ? 'Spend is ${anomaly.percentageChange.toStringAsFixed(0)}% higher than usual'
        : 'Spend is ${anomaly.percentageChange.toStringAsFixed(0)}% higher than usual';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(mainIcon, color: themeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaignName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Campaign',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            description,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  isSpike ? Icons.arrow_outward : Icons.south_east,
                  themeColor,
                  currentStr,
                  isSpike ? 'Spend' : 'Spend',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  Icons.subdirectory_arrow_right,
                  AppTheme.primaryTeal,
                  expectedStr,
                  'Expected',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  isSpike ? Icons.arrow_outward : Icons.south_east,
                  themeColor,
                  changeStr,
                  'Change',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
