import 'package:expense_tracker_frontend/widgets/hover_elevated_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';
import 'login_screen.dart';
import '../theme/theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String name;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> txs = [];
  double income = 0;
  double expense = 0;
  bool loading = true;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 🔄 LOAD / REFRESH DATA
  Future<void> _loadData({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => loading = true);
    } else {
      setState(() => refreshing = true);
    }

    final raw = await ApiService.getTransactions(widget.userId);

    final data = raw.map(TransactionModel.fromJson).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    double i = 0, e = 0;
    for (final t in data) {
      t.isIncome ? i += t.amount : e += t.amount;
    }

    if (!mounted) return;

    setState(() {
      txs = data;
      income = i;
      expense = e;
      loading = false;
      refreshing = false;
    });
  }

  double get balance => income - expense;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final isDark = theme.themeMode == ThemeMode.dark;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        /// 🚪 LOGOUT
        leading: IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
        ),

        title: Text('Hi ${widget.name} 👋'),

        actions: [
          /// 🔄 REFRESH
          IconButton(
            tooltip: 'Refresh',
            onPressed: refreshing ? null : () => _loadData(showLoader: false),
            icon: refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),

          /// 🌙 THEME TOGGLE
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => theme.toggle(!isDark),
          ),

          /// 📊 ANALYTICS
          IconButton(
            tooltip: 'Analytics',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyticsScreen(
                    income: income,
                    expense: expense,
                    transactions: txs,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _balanceCard(),

          /// 🧾 RECENT TRANSACTIONS TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// 📜 TRANSACTION LIST
          Expanded(
            child: txs.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadData(showLoader: false),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemCount: txs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final tx = txs[i];

                        return HoverElevatedCard(
                          normalElevation: 2,
                          hoverElevation: 8,
                          shadowColor: tx.isIncome
                              ? Colors.green.withOpacity(0.25)
                              : Colors.redAccent.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          child: TransactionTile(tx: tx),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      /// ➕ ADD TRANSACTION
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(userId: widget.userId),
            ),
          );
          if (refresh == true) {
            _loadData(showLoader: false);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 💳 BALANCE CARD
  Widget _balanceCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          children: [
            /// BALANCE
            Text(
              'Balance',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${balance.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 18),

            /// MINI STATS (ELEVATED)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCard(
                  'Income',
                  income,
                  Colors.green,
                  Icons.arrow_downward,
                ),
                _statCard(
                  'Expense',
                  expense,
                  Colors.redAccent,
                  Icons.arrow_upward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 MINI STAT CARD WITH ELEVATION
  Widget _statCard(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return HoverElevatedCard(
      normalElevation: 2,
      hoverElevation: 6,
      shadowColor: color.withOpacity(0.35),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '₹${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
