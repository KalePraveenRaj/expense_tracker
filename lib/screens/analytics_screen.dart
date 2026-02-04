import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/expense_trend_chart.dart';
import '../widgets/expense_bar_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/income_category_pie_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final double income;
  final double expense;
  final List<TransactionModel> transactions;

  const AnalyticsScreen({
    super.key,
    required this.income,
    required this.expense,
    required this.transactions,
  });

  double get balance => income - expense;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Trend'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildTrendTab(),
            _buildSummaryTab(),
          ],
        ),
      ),
    );
  }

  // ================= OVERVIEW TAB =================

  Widget _buildOverviewTab() {
    return _chartPage(
      title: 'Overview',
      subtitle: 'Overall, income & expense category distribution',
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              if (isWide) {
                /// 🖥 DESKTOP / TABLET
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ExpensePieChart(
                        income: income,
                        expense: expense,
                      ),
                    ),
                    const VerticalDivider(width: 32),
                    Expanded(
                      child: CategoryPieChart(
                        transactions: transactions,
                      ),
                    ),
                    const VerticalDivider(width: 32),
                    Expanded(
                      child: IncomeCategoryPieChart(
                        transactions: transactions,
                      ),
                    ),
                  ],
                );
              }

              /// 📱 MOBILE
              return Column(
                children: [
                  ExpensePieChart(
                    income: income,
                    expense: expense,
                  ),
                  const Divider(height: 32),
                  CategoryPieChart(
                    transactions: transactions,
                  ),
                  const Divider(height: 32),
                  IncomeCategoryPieChart(
                    transactions: transactions,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= TREND TAB =================

  Widget _buildTrendTab() {
    return _chartPage(
      title: 'Transaction Trend',
      subtitle: 'How income & expense change over time',
      child: ExpenseTrendChart(
        transactions: transactions,
      ),
    );
  }

  // ================= SUMMARY TAB =================

  Widget _buildSummaryTab() {
    return _chartPage(
      title: 'Financial Summary',
      subtitle: 'Income, expense & balance comparison',
      child: ExpenseBarChart(
        income: income,
        expense: expense,
        balance: balance,
      ),
    );
  }

  // ================= COMMON PAGE LAYOUT =================

  Widget _chartPage({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
