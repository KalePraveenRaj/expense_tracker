import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatefulWidget {
  final double income;
  final double expense;

  const ExpensePieChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.income + widget.expense;
    final balance = widget.income - widget.expense;

    if (total == 0) {
      return const Center(child: Text('No data'));
    }

    return Card(
      elevation: 4,
      child: SizedBox(
        height: 340,
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// PIE CHART
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 70,
                      sectionsSpace: 3,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            touchedIndex =
                                response?.touchedSection?.touchedSectionIndex ??
                                    -1;
                          });
                        },
                      ),
                      sections: [
                        _buildSection(
                          index: 0,
                          value: widget.income,
                          color: Colors.green,
                          label: '₹ ${widget.income.toStringAsFixed(2)}',
                        ),
                        _buildSection(
                          index: 1,
                          value: widget.expense,
                          color: Colors.redAccent,
                          label: '₹ ${widget.expense.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),

                  /// CENTER BALANCE
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: balance >= 0 ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// LEGEND
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Legend(color: Colors.green, label: 'Income'),
                _Legend(color: Colors.redAccent, label: 'Expense'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 PIE SLICE WITH HOVER LABEL BESIDE SLICE
  PieChartSectionData _buildSection({
    required int index,
    required double value,
    required Color color,
    required String label,
  }) {
    final isTouched = index == touchedIndex;

    return PieChartSectionData(
      value: value,
      color: color,
      radius: isTouched ? 54 : 48,
      title: '', // ❌ no text inside slice

      /// ✅ SHOW LABEL ONLY ON HOVER
      badgeWidget: isTouched
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          : null,

      /// 🎯 POSITION LABEL OUTSIDE SLICE (LIKE YOUR IMAGE)
      badgePositionPercentageOffset: 1.25,
    );
  }
}

/// LEGEND
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
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
