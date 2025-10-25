import 'package:courency_converter/core/utils/chart_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CurrencyChart extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;

  const CurrencyChart({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = getDummyChartData(
      fromCurrency,
      toCurrency,
    ); // ✅ Now it works

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Exchange Rate Trend: $fromCurrency → $toCurrency (Last 7 Days)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "1 $fromCurrency = ${chartData.last.toStringAsFixed(2)} $toCurrency",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      spots:
                          chartData
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
