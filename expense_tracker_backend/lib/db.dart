import 'package:mysql_client/mysql_client.dart';

const String dbName = 'expense_tracker';

Future<MySQLConnection> dbConnection() async {
  final conn = await MySQLConnection.createConnection(
    host: 'localhost',
    port: 3306,
    userName: 'root',
    password: 'rgukt123',
    databaseName: dbName,
  );
  await conn.connect();
  return conn;
}

Future<void> initDatabase() async {
  final base = await MySQLConnection.createConnection(
    host: 'localhost',
    port: 3306,
    userName: 'root',
    password: 'rgukt123',
  );

  await base.connect();
  await base.execute('CREATE DATABASE IF NOT EXISTS $dbName');
  await base.close();

  final conn = await dbConnection();

  await conn.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100),
      email VARCHAR(100) UNIQUE,
      password VARCHAR(255),
      salary DOUBLE
    )
  ''');

  await conn.execute('''
    CREATE TABLE IF NOT EXISTS transactions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      title VARCHAR(100) NOT NULL,
      amount DOUBLE DEFAULT 0,
      extra_income DOUBLE DEFAULT 0,
      category VARCHAR(50),
      date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
    )
  ''');

  await conn.close();
  print('✅ DB READY');
}
