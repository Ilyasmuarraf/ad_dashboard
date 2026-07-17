import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../core/theme.dart';
import '../../models/campaign.dart';
import '../screens/campaign_detail_screen.dart';

class SpendSummaryScreen extends ConsumerStatefulWidget {
  const SpendSummaryScreen({super.key});

  @override
  ConsumerState<SpendSummaryScreen> createState() => _SpendSummaryScreenState();
}

class _SpendSummaryScreenState extends ConsumerState<SpendSummaryScreen> {
  String currentRange = 'Last 7 Days';

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(spendSummaryProvider(currentRange));
    final campaignsAsync = ref.watch(campaignsProvider);
    final campaignsList = campaignsAsync.value;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.menu, color: AppTheme.textPrimary),
        title: const Text(
          'Spend Summary',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
        error: (err, stack) => const Center(
          child: Text(
            'Failed to load data',
            style: TextStyle(color: AppTheme.alertSpike),
          ),
        ),
        data: (data) {
          final responseData = data['summary'] ?? data;

          final double totalSpend = (responseData['total_spend'] ?? 0)
              .toDouble();
          final List<dynamic> topCampaigns =
              responseData['top_campaigns'] ?? [];

          final List<dynamic> rawChannels = responseData['by_channel'] ?? [];
          final Map<String, double> channels = {};

          for (final item in rawChannels) {
            if (item is Map) {
              final String name = (item['channel'] ?? 'Unknown').toString();
              final double spend = (item['spend'] ?? 0).toDouble();
              if (spend > 0) channels[name] = spend;
            }
          }

          return RefreshIndicator(
            color: AppTheme.primaryTeal,
            backgroundColor: AppTheme.backgroundDark,
            onRefresh: () async {
              ref.invalidate(spendSummaryProvider(currentRange));
              try {
                await ref.read(spendSummaryProvider(currentRange).future);
              } catch (_) {}
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalSpendCard(totalSpend),
                  const SizedBox(height: 16),
                  _buildDonutChartCard(channels),
                  const SizedBox(height: 16),
                  _buildTopCampaignsCard(topCampaigns, campaignsList),
                  const SizedBox(height: 16),
                  _buildDateRangeFilter(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalSpendCard(double totalSpend) {
    final String formattedSpend = totalSpend
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
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
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Spend',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formattedSpend,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'SAR',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(Map<String, double> channels) {
    final List<Color> palette = [
      AppTheme.primaryTeal,
      const Color(0xFF3B82F6),
      const Color(0xFFA855F7),
      const Color(0xFFEAB308),
    ];

    final bool hasData = channels.isNotEmpty;
    final double totalChartSpend = channels.values.fold(
      0,
      (sum, val) => sum + val,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spend by channel',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 32,
                    startDegreeOffset: -90,
                    sections: hasData
                        ? channels.entries.map((entry) {
                            final int idx = channels.keys.toList().indexOf(
                              entry.key,
                            );
                            return PieChartSectionData(
                              color: palette[idx % palette.length],
                              value: entry.value,
                              radius: 28,
                              showTitle: false,
                            );
                          }).toList()
                        : [
                            PieChartSectionData(
                              color: const Color(0xFF2C2C2C),
                              value: 100,
                              radius: 28,
                              showTitle: false,
                            ),
                          ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: !hasData
                    ? const Text(
                        'No channel data',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: channels.length,
                        itemBuilder: (context, idx) {
                          final String key = channels.keys.toList()[idx];
                          final double value = channels.values.toList()[idx];
                          final color = palette[idx % palette.length];

                          final double percentage = totalChartSpend > 0
                              ? (value / totalChartSpend) * 100
                              : 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    key,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCampaignsCard(
    List<dynamic> topCampaigns,
    List<Campaign>? campaignsList,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 3 Campaigns by CTR',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          if (topCampaigns.isEmpty)
            const Text(
              'No metrics available.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            )
          else
            ...List.generate(topCampaigns.length, (index) {
              final item = topCampaigns[index];
              final String id = item['id'] ?? '';
              final String name = item['name'] ?? 'Unknown Campaign';

              final double rawCtr = (item['ctr'] ?? 0).toDouble();
              final double ctr = rawCtr < 1.0 && rawCtr > 0
                  ? rawCtr * 100
                  : rawCtr;

              return Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (campaignsList == null) return;
                      final int campIndex = campaignsList.indexWhere(
                        (c) => c.id == id,
                      );
                      if (campIndex != -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampaignDetailScreen(
                              campaign: campaignsList[campIndex],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Campaign details not available.'),
                            backgroundColor: AppTheme.alertSpike,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppTheme.primaryTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.campaign,
                            size: 20,
                            color: AppTheme.primaryTeal,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${ctr.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppTheme.statusActive,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_outward,
                                size: 14,
                                color: AppTheme.statusActive,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < topCampaigns.length - 1)
                    const Divider(
                      color: Color(0xFF2C2C2C),
                      height: 16,
                      thickness: 1,
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    final List<String> ranges = ['Last 7 Days', 'Last 14 Days', 'Last 30 Days'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ranges.map((r) {
            final bool isSelected = r == currentRange;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => currentRange = r),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.transparent : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryTeal
                          : const Color(0xFF2C2C2C),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      r,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
