import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../lib/db.dart';
import '../lib/auth_api.dart';
import '../lib/transaction_api.dart';

Future<void> main() async {
  await initDatabase();

  final router = Router()
    ..post('/register', register)
    ..post('/login', login)
    ..post('/transaction', addTransaction)
    ..get('/transactions', getTransactions);

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router);

  await serve(handler, '0.0.0.0', 8080);
  print('🚀 Server running at http://localhost:8080');
}
