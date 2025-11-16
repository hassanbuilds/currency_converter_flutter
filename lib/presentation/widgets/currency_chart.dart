import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CurrencyChart extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final List<double> chartData;
  final bool isLoading;
  final String? error;

  const CurrencyChart({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.chartData,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    // Loading state
    if (isLoading) {
      return SizedBox(
        height: isTablet ? 300 : size.height * 0.3,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (error != null) {
      return SizedBox(
        height: isTablet ? 300 : size.height * 0.3,
        child: Center(child: Text('Error loading chart: $error')),
      );
    }

    // No data
    if (chartData.isEmpty) {
      return SizedBox(
        height: isTablet ? 300 : size.height * 0.3,
        child: const Center(child: Text('No chart data available')),
      );
    }

    // Determine min & max for chart
    final minY = chartData.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = chartData.reduce((a, b) => a > b ? a : b) * 1.05;

    return Card(
      elevation: isTablet ? 6 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? size.width * 0.02 : 8,
        vertical: 12,
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Exchange Rate Trend: $fromCurrency → $toCurrency (Last ${chartData.length} Points)",
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              "1 $fromCurrency = ${chartData.last.toStringAsFixed(2)} $toCurrency",
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            SizedBox(height: isTablet ? 16 : 12),

            /// Make chart take remaining available space without overflowing
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: isTablet ? 4 : 3,
                        spots:
                            chartData
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  key: ValueKey(chartData.hashCode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
