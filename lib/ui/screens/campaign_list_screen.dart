import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/theme.dart';
import '../widgets/campaign_card.dart';

class CampaignListScreen extends ConsumerStatefulWidget {
  const CampaignListScreen({super.key});

  @override
  ConsumerState<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends ConsumerState<CampaignListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.menu, color: AppTheme.textPrimary),
        title: const Text(
          'Campaign List',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search Campaigns...',
                hintStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: const Icon(
                  Icons.tune,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppTheme.cardDark,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.primaryTeal),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: ['All', 'Active', 'Paused'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2C2C2C)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: campaignsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              ),
              error: (err, stack) => const Center(
                child: Text(
                  'Failed to load campaigns.',
                  style: TextStyle(color: AppTheme.alertSpike),
                ),
              ),
              data: (campaigns) {
                final filteredCampaigns = campaigns.where((c) {
                  final matchesSearch = c.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                  final matchesFilter =
                      _selectedFilter == 'All' ||
                      c.status.toLowerCase() == _selectedFilter.toLowerCase();
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredCampaigns.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching campaigns found.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryTeal,
                  backgroundColor: AppTheme.backgroundDark,
                  onRefresh: () async {
                    ref.invalidate(campaignsProvider);
                    try {
                      await ref.read(campaignsProvider.future);
                    } catch (_) {}
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredCampaigns.length,
                    itemBuilder: (context, index) {
                      return CampaignCard(campaign: filteredCampaigns[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
