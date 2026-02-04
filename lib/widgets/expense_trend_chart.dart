import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class ExpenseTrendChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ExpenseTrendChart({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No trend data'));
    }

    /// ✅ LEFT → RIGHT (CHRONOLOGICAL)
    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      final spot = FlSpot(i.toDouble(), t.amount);

      if (t.isIncome) {
        incomeSpots.add(spot);
      } else {
        expenseSpots.add(spot);
      }
    }

    final maxValue =
        sorted.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    final maxY = maxValue * 1.4;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 📈 LINE CHART
              SizedBox(
                height: 230,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (sorted.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,

                    /// 🎯 TRANSPARENT TOOLTIP
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,

                        /// ✅ TRANSPARENT BACKGROUND
                        tooltipBgColor: Colors.transparent,
                        tooltipRoundedRadius: 0,
                        tooltipPadding: EdgeInsets.zero,

                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final tx = sorted[spot.x.toInt()];
                            final color =
                                tx.isIncome ? Colors.green : Colors.redAccent;

                            return LineTooltipItem(
                              '${tx.title}\n₹${tx.amount.toStringAsFixed(0)}',
                              TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: color,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                    ),

                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),

                    lineBarsData: [
                      _line(expenseSpots, Colors.redAccent),
                      _line(incomeSpots, Colors.green),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🧭 LEGEND
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Legend(color: Colors.green, label: 'Income'),
                  SizedBox(width: 24),
                  _Legend(color: Colors.redAccent, label: 'Expense'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📊 LINE STYLE
  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: 3,
      color: color,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.12),
      ),
    );
  }
}

/// 🧭 LEGEND ITEM
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
