import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  /// 🔑 LOGIN
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return res.statusCode == 200 ? jsonDecode(res.body) : null;
  }

  /// 📝 REGISTER (✅ FIXED: SALARY INCLUDED)
  static Future<bool> register(
    String name,
    String email,
    String password,
    double salary,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'salary': salary, // ✅ IMPORTANT
      }),
    );

    return res.statusCode == 200;
  }

  /// ➕ ADD TRANSACTION
  static Future<bool> addTransaction({
    required int userId,
    required String title,
    required double amount,
    required String category,
    required bool isIncome,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transaction'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'amount': isIncome ? 0 : amount,
        'extra_income': isIncome ? amount : 0,
        'category': category,
      }),
    );

    return res.statusCode == 200;
  }

  /// 📄 GET TRANSACTIONS
  static Future<List<Map<String, dynamic>>> getTransactions(
    int userId,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/transactions?user_id=$userId'),
    );

    return res.statusCode == 200
        ? List<Map<String, dynamic>>.from(jsonDecode(res.body))
        : [];
  }
}
