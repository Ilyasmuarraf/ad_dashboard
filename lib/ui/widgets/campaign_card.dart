import 'package:flutter/material.dart';
import '../../models/campaign.dart';
import '../../core/theme.dart';
import '../screens/campaign_detail_screen.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;

  const CampaignCard({super.key, required this.campaign, this.onTap});

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
  Widget build(BuildContext context) {
    final double calculatedCtr = campaign.impressions > 0
        ? (campaign.clicks / campaign.impressions) * 100
        : 0.0;

    final bool isActive = campaign.status.toLowerCase() == 'active';
    final Color statusColor = isActive
        ? AppTheme.statusActive
        : const Color(0xFFF59E0B);

    const double budgetCap = 10000.0;
    final double progressFactor = (campaign.totalSpend / budgetCap).clamp(
      0.0,
      1.0,
    );
    final int percentage = (progressFactor * 100).toInt();

    return GestureDetector(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampaignDetailScreen(campaign: campaign),
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: '${campaign.id}-icon',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppTheme.primaryTeal,
                      size: 24,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          campaign.objective,
                          style: const TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      campaign.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.more_horiz,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Total spend',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${_formatCurrency(campaign.totalSpend)} SAR',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  ' / ${_formatCurrency(budgetCap)} SAR',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressFactor,
                minHeight: 4,
                backgroundColor: const Color(0xFF1E1E1E),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildColumnMetricValue(
                  _formatNumber(campaign.impressions),
                  'Impressions',
                ),
                _buildColumnMetricValue(
                  _formatNumber(campaign.clicks),
                  'Clicks',
                ),
                _buildColumnMetricValue(
                  '${calculatedCtr.toStringAsFixed(2)}%',
                  'CTR',
                  hasInfo: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start date',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      campaign.startDate,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                const Icon(
                  Icons.group_outlined,
                  size: 14,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audience',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      campaign.audience,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildColumnMetricValue(
  String value,
  String label, {
  bool hasInfo = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          if (hasInfo) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.info_outline,
              color: AppTheme.textSecondary,
              size: 12,
            ),
          ],
        ],
      ),
    ],
  );
}
