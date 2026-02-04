import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class CategoryPieChart extends StatefulWidget {
  final List<TransactionModel> transactions;

  const CategoryPieChart({
    super.key,
    required this.transactions,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expenseTxs = widget.transactions.where((t) => !t.isIncome).toList();

    if (expenseTxs.isEmpty) {
      return const Center(child: Text('No expense data'));
    }

    final Map<String, double> categoryMap = {};

    for (final t in expenseTxs) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }

    final entries = categoryMap.entries.toList();

    return Column(
      children: [
        const Text(
          'Expense by Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 55,
              sectionsSpace: 3,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    touchedIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: List.generate(entries.length, (i) {
                final e = entries[i];
                final isTouched = i == touchedIndex;
                final color = Colors.primaries[i % Colors.primaries.length];

                return PieChartSectionData(
                  value: e.value,
                  color: color,
                  radius: isTouched ? 52 : 46,
                  title: '',
                  badgeWidget: isTouched ? _badge(e.key, e.value, color) : null,
                  badgePositionPercentageOffset: 1.3,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String category, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      child: Text(
        '$category\n₹ ${amount.toStringAsFixed(0)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
