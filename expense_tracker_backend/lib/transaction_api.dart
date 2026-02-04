import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'db.dart';

Future<Response> addTransaction(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final conn = await dbConnection();

  await conn.execute('''
    INSERT INTO transactions
      (user_id, title, amount, extra_income, category)
    VALUES
      (:user_id, :title, :amount, :extra_income, :category)
  ''', {
    'user_id': body['user_id'],
    'title': body['title'],
    'amount': body['amount'] ?? 0,
    'extra_income': body['extra_income'] ?? 0,
    'category': body['category'],
  });

  await conn.close();

  return Response.ok(
    jsonEncode({'success': true}),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> getTransactions(Request req) async {
  final userId = int.parse(req.url.queryParameters['user_id']!);
  final conn = await dbConnection();

  final res = await conn.execute('''
    SELECT id, title, amount, extra_income, category, date
    FROM transactions
    WHERE user_id = :user_id
    ORDER BY date DESC, id DESC
  ''', {'user_id': userId});

  await conn.close();

  final data = res.rows.map((r) {
    final income =
        double.tryParse(r.colByName('extra_income')?.toString() ?? '0') ?? 0;
    final expense =
        double.tryParse(r.colByName('amount')?.toString() ?? '0') ?? 0;

    return {
      'id': r.colByName('id'),
      'title': r.colByName('title'),
      'amount': income > 0 ? income : expense,
      'category': r.colByName('category'),
      'date': r.colByName('date'),
      'isIncome': income > 0,
    };
  }).toList();

  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}
