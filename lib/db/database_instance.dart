import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crud_project_pencatatan_keuangan/models/transaksi_model.dart';

class DatabaseInstance {
  final String _databaseName = "database_keuangan.db";
  final int _databaseVersion = 1;

  Database? _database;

  Future<Database> database() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE transaksi (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type INTEGER, total INTEGER, created_at TEXT, updated_at TEXT)');
  }

  Future<List<TransaksiModel>> getAll() async {
    final data = await (await database()).query('transaksi', orderBy: 'id DESC');
    return data.map((e) => TransaksiModel.fromJson(e)).toList();
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final query = await database();
    return await query.insert('transaksi', row);
  }

  Future<int> totalPemasukan() async {
    final query = await database();
    final result = await query.rawQuery('SELECT SUM(total) as total FROM transaksi WHERE type = 1');
    return result.first['total'] != null ? int.parse(result.first['total'].toString()) : 0;
  }

  Future<int> totalPengeluaran() async {
    final query = await database();
    final result = await query.rawQuery('SELECT SUM(total) as total FROM transaksi WHERE type = 2');
    return result.first['total'] != null ? int.parse(result.first['total'].toString()) : 0;
  }

  Future<int> hapus(int id) async {
    final query = await database();
    return await query.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }

  // Di dalam file database_instance.dart
Future<int> update(int id, Map<String, dynamic> row) async {
  Database db = await database();
  return await db.update('transaksi', row, where: 'id = ?', whereArgs: [id]);
}
}