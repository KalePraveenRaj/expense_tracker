import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tx.isIncome ? Colors.green : Colors.redAccent,
          child: Icon(
            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(tx.title),
        subtitle: Text('${tx.category} • ${tx.date.toString().split(' ')[0]}'),
        trailing: Text(
          '₹${tx.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: tx.isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
