import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/formatters.dart';

class BarSeriesPoint {
  final String label;
  final double primary;
  final double secondary;
  const BarSeriesPoint(this.label, this.primary, {this.secondary = 0});
}

/// Grouped/single bar chart. When [secondaryColor] is null only [primary] is
/// drawn; otherwise a paired (e.g. income vs expense) chart is rendered.
class GroupedBarChart extends StatelessWidget {
  final List<BarSeriesPoint> points;
  final Color primaryColor;
  final Color? secondaryColor;
  final double height;

  const GroupedBarChart({
    super.key,
    required this.points,
    required this.primaryColor,
    this.secondaryColor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    double maxV = 1;
    for (final p in points) {
      maxV = [maxV, p.primary, p.secondary].reduce((a, b) => a > b ? a : b);
    }
    final maxY = (maxV * 1.25).clamp(1.0, double.infinity);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                AppFormatters.currency(rod.toY),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (value, _) => Text(
                  AppFormatters.shortCurrency(value),
                  style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(points[i].label,
                        style: TextStyle(
                            fontSize: 10, color: scheme.onSurfaceVariant)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].primary,
                    color: primaryColor,
                    width: secondaryColor == null ? 16 : 9,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  if (secondaryColor != null)
                    BarChartRodData(
                      toY: points[i].secondary,
                      color: secondaryColor,
                      width: 9,
                      borderRadius: BorderRadius.circular(4),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
