import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/forecast_data.dart';
import '../../core/theme.dart';

class ForecastChart extends StatelessWidget {
  final List<DailyMetric> history;
  final List<ForecastPoint> forecast;

  const ForecastChart({
    super.key,
    required this.history,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty && forecast.isEmpty) {
      return const Center(
        child: Text(
          'No metric performance data points returned from server.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      );
    }

    final List<FlSpot> historySpots = [];
    for (int i = 0; i < history.length; i++) {
      final dynamic h = history[i];
      final double val = (h.ctr ?? h.value ?? h.ctrValue ?? h.metric ?? 0.0)
          .toDouble();
      historySpots.add(FlSpot(i.toDouble(), val < 1.0 ? val * 100 : val));
    }

    final List<FlSpot> forecastSpots = [];
    final int offset = history.length;
    for (int i = 0; i < forecast.length; i++) {
      final dynamic f = forecast[i];
      final double expected =
          (f.expectedCtr ?? f.expected ?? f.value ?? f.expectedValue ?? 0.0)
              .toDouble();
      forecastSpots.add(
        FlSpot(
          (offset + i).toDouble(),
          expected < 1.0 ? expected * 100 : expected,
        ),
      );
    }

    final List<FlSpot> upperBoundSpots = [];
    for (int i = 0; i < forecast.length; i++) {
      final dynamic f = forecast[i];
      final double upper =
          (f.upperBound ?? f.upper ?? f.high ?? f.upperValue ?? 0.0).toDouble();
      upperBoundSpots.add(
        FlSpot((offset + i).toDouble(), upper < 1.0 ? upper * 100 : upper),
      );
    }

    final List<FlSpot> lowerBoundSpots = [];
    for (int i = 0; i < forecast.length; i++) {
      final dynamic f = forecast[i];
      final double lower =
          (f.lowerBound ?? f.lower ?? f.low ?? f.lowerValue ?? 0.0).toDouble();
      lowerBoundSpots.add(
        FlSpot((offset + i).toDouble(), lower < 1.0 ? lower * 100 : lower),
      );
    }

    final List<LineChartBarData> barDataList = [];

    if (historySpots.isNotEmpty) {
      barDataList.add(
        LineChartBarData(
          spots: historySpots,
          isCurved: true,
          color: AppTheme.primaryTeal,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    if (forecastSpots.isNotEmpty) {
      barDataList.add(
        LineChartBarData(
          spots: forecastSpots,
          isCurved: true,
          color: AppTheme.primaryTeal.withOpacity(0.5),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
      );

      barDataList.add(
        LineChartBarData(
          spots: upperBoundSpots,
          isCurved: true,
          color: Colors.transparent,
          dotData: const FlDotData(show: false),
        ),
      );

      barDataList.add(
        LineChartBarData(
          spots: lowerBoundSpots,
          isCurved: true,
          color: Colors.transparent,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        minX: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Color(0xFF2C2C2C), strokeWidth: 1),
          getDrawingVerticalLine: (value) {
            if (value == offset.toDouble() && offset > 0) {
              return const FlLine(
                color: AppTheme.textSecondary,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            }
            return const FlLine(color: Colors.transparent);
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                String dateStr = '';

                if (index >= 0 && index < history.length) {
                  final dynamic h = history[index];
                  dateStr = (h.date ?? h.timestamp ?? h.day ?? h.time ?? '')
                      .toString();
                } else if (index >= history.length &&
                    index < history.length + forecast.length) {
                  final dynamic f = forecast[index - history.length];
                  dateStr = (f.date ?? f.timestamp ?? f.day ?? f.time ?? '')
                      .toString();
                }

                if (dateStr.isNotEmpty && dateStr.length >= 10) {
                  try {
                    final DateTime parsed = DateTime.parse(dateStr);
                    final List<String> months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];
                    dateStr =
                        '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]}';
                  } catch (_) {}
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: barDataList,
        betweenBarsData: forecastSpots.isNotEmpty && barDataList.length >= 3
            ? [
                BetweenBarsData(
                  fromIndex: barDataList.length - 2,
                  toIndex: barDataList.length - 1,
                  color: AppTheme.primaryTeal.withOpacity(0.12),
                ),
              ]
            : [],
      ),
    );
  }
}
