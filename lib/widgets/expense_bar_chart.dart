import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseBarChart extends StatefulWidget {
  final double income;
  final double expense;
  final double balance;

  const ExpenseBarChart({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  State<ExpenseBarChart> createState() => _ExpenseBarChartState();
}

class _ExpenseBarChartState extends State<ExpenseBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final values = [
      widget.income,
      widget.expense,
      widget.balance < 0 ? 0 : widget.balance,
    ];

    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.4)
        .clamp(100, double.infinity);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: 360,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              maxY: maxY.toDouble(),

              /// 👆 TOUCH
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  setState(() {
                    touchedIndex = response?.spot?.touchedBarGroupIndex ?? -1;
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.transparent, // ✅ transparent
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 6,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,

                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final color = groupIndex == 0
                        ? Colors.green
                        : groupIndex == 1
                            ? Colors.redAccent
                            : Colors.purple;

                    return BarTooltipItem(
                      '₹${rod.toY.toStringAsFixed(0)}',
                      TextStyle(
                        color: color, // ✅ same as bar
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      switch (v.toInt()) {
                        case 0:
                          return _barTitle('Income', Colors.green);
                        case 1:
                          return _barTitle('Expense', Colors.redAccent);
                        case 2:
                          return _barTitle('Balance', Colors.purple);
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),

              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),

              barGroups: List.generate(values.length, (i) {
                final isTouched = i == touchedIndex;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      // 🔼 lift bar slightly on hover
                      toY: isTouched
                          ? values[i] + (maxY * 0.03)
                          : values[i].toDouble(),

                      width: 22, // ❌ no widening
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(isTouched ? 14 : 6),
                      ),

                      color: _barColor(i).withOpacity(isTouched ? 1 : 0.85),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Color _barColor(int i) {
    if (i == 0) return Colors.green;
    if (i == 1) return Colors.redAccent;
    return Colors.purple;
  }

  Widget _barTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
