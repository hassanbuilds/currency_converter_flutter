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
    final chartData = getDummyChartData(fromCurrency, toCurrency);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Card(
            elevation: isTablet ? 6 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.02 : 0,
              vertical: 12,
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exchange Rate Trend: $fromCurrency → $toCurrency (Last 7 Days)",
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
                  SizedBox(height: isTablet ? 24 : 16),

                  ///  Responsive chart container inside scrollable parent
                  SizedBox(
                    height:
                        constraints.maxHeight * 0.35 > 250
                            ? 250
                            : constraints.maxHeight * 0.35,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
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
                                    .map(
                                      (e) => FlSpot(e.key.toDouble(), e.value),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
