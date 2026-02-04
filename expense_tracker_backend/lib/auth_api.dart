import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'db.dart';
import 'package:mysql_client/mysql_client.dart' show MySQLConnection;

String hash(String v) => sha256.convert(utf8.encode(v)).toString();

/// ✅ Ensure salary exists for current month
Future<void> ensureMonthlySalary(
  MySQLConnection conn,
  int userId,
  double salary,
) async {
  if (salary <= 0) return;

  final check = await conn.execute('''
    SELECT id
    FROM transactions
    WHERE user_id = :user_id
      AND category = 'Salary'
      AND YEAR(date) = YEAR(CURRENT_DATE)
      AND MONTH(date) = MONTH(CURRENT_DATE)
    LIMIT 1
  ''', {'user_id': userId});

  if (check.rows.isEmpty) {
    await conn.execute('''
      INSERT INTO transactions
        (user_id, title, extra_income, category)
      VALUES
        (:user_id, 'Salary', :salary, 'Salary')
    ''', {
      'user_id': userId,
      'salary': salary,
    });
  }
}

/// 📝 REGISTER
Future<Response> register(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final conn = await dbConnection();

  await conn.execute('''
    INSERT INTO users (name, email, password, salary)
    VALUES (:name, :email, :password, :salary)
  ''', {
    'name': body['name'],
    'email': body['email'],
    'password': hash(body['password']),
    'salary': body['salary'],
  });

  await conn.close();

  return Response.ok(
    jsonEncode({'success': true}),
    headers: {'Content-Type': 'application/json'},
  );
}

/// 🔑 LOGIN
Future<Response> login(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final conn = await dbConnection();

  final res = await conn.execute('''
    SELECT id, name, salary, password
    FROM users
    WHERE email = :email
  ''', {'email': body['email']});

  if (res.rows.isEmpty ||
      res.rows.first.colByName('password') != hash(body['password'])) {
    await conn.close();
    return Response.forbidden(
      jsonEncode({'error': 'Invalid credentials'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final row = res.rows.first;
  final userId = int.parse(row.colByName('id').toString());
  final salary = double.parse(row.colByName('salary').toString());

  /// ✅ Insert salary if needed
  await ensureMonthlySalary(conn, userId, salary);

  await conn.close();

  return Response.ok(
    jsonEncode({
      'user_id': userId,
      'name': row.colByName('name'),
      'salary': salary,
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
