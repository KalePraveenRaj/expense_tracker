import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final int userId;

  const AddTransactionScreen({super.key, required this.userId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  String? titleError;
  String? amountError;
  String? categoryError;

  bool isIncome = false;
  bool loading = false;
  String? selectedCategory;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  /// 📂 PREDEFINED CATEGORIES
  final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Bonus',
    'Other',
  ];

  final List<String> expenseCategories = [
    'Food',
    'Rent',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Other',
  ];

  List<String> get categories =>
      isIncome ? incomeCategories : expenseCategories;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// 💾 SAVE TRANSACTION
  Future<void> save() async {
    final title = titleCtrl.text.trim();
    final amountText = amountCtrl.text.trim();

    setState(() {
      titleError = title.isEmpty ? 'Title is required' : null;

      amountError = amountText.isEmpty
          ? 'Amount is required'
          : double.tryParse(amountText) == null
              ? 'Enter a valid number'
              : null;

      categoryError = selectedCategory == null ? 'Category is required' : null;
    });

    if (titleError != null || amountError != null || categoryError != null) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => loading = true);

    final success = await ApiService.addTransaction(
      userId: widget.userId,
      title: title,
      amount: double.parse(amountText),
      category: selectedCategory!,
      isIncome: isIncome,
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (success) {
      /// 🔥 Notify previous screen to reload (latest on top)
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save transaction')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (_, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// 📝 TITLE
                  TextField(
                    controller: titleCtrl,
                    onChanged: (_) => setState(() => titleError = null),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: const Icon(Icons.title),
                      errorText: titleError,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 💰 AMOUNT
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => amountError = null),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      errorText: amountError,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 📂 CATEGORY
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      errorText: categoryError,
                    ),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedCategory = v;
                        categoryError = null;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  /// 🔁 INCOME / EXPENSE
                  SwitchListTile(
                    title: const Text('Extra Income'),
                    secondary: const Icon(Icons.trending_up),
                    value: isIncome,
                    onChanged: (v) {
                      setState(() {
                        isIncome = v;
                        selectedCategory = null;
                        categoryError = null;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// 💾 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(loading ? 'Saving...' : 'Save Transaction'),
                      onPressed: loading ? null : save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
