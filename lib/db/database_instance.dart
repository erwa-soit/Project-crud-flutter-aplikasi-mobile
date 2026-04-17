import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crud_project_pencatatan_keuangan/models/transaksi_model.dart';

class DatabaseInstance {
  final String namaDatabase = 'keuangan.db';
  final int versiDatabase = 1;

  // Nama Tabel dan Kolom
  final String namaTabel = 'transaksi';
  final String id = 'id';
  final String name = 'name';
  final String type = 'type'; // 1 untuk pemasukan, 2 untuk pengeluaran
  final String total = 'total';
  final String createdAt = 'created_at';
  final String updatedAt = 'updated_at';

  Database? _database;

  Future<Database> database() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory berkasDirektori = await getApplicationDocumentsDirectory();
    String path = join(berkasDirektori.path, namaDatabase);

    return await openDatabase(path, version: versiDatabase, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $namaTabel ($id INTEGER PRIMARY KEY AUTOINCREMENT, $name TEXT, $type INTEGER, $total INTEGER, $createdAt TEXT, $updatedAt TEXT)');
  }

  // Fungsi untuk mengambil semua data
  Future<List<TransaksiModel>> all() async {
    final data = await _database!.query(namaTabel, orderBy: '$id DESC');
    List<TransaksiModel> result =
        data.map((e) => TransaksiModel.fromJson(e)).toList();
    return result;
  }

  // Fungsi Insert data
  Future<int> insert(Map<String, dynamic> row) async {
    final query = await _database!.insert(namaTabel, row);
    return query;
  }

  // PERBAIKAN: Fungsi Total Pemasukan agar tidak Error Null
  Future<int> totalPemasukan() async {
    var query = await _database!.rawQuery(
        "SELECT SUM($total) as total FROM $namaTabel WHERE $type = 1");
    
    if (query.first['total'] == null) {
      return 0;
    }
    return int.parse(query.first['total'].toString());
  }

  // PERBAIKAN: Fungsi Total Pengeluaran agar tidak Error Null
  Future<int> totalPengeluaran() async {
    var query = await _database!.rawQuery(
        "SELECT SUM($total) as total FROM $namaTabel WHERE $type = 2");
    
    if (query.first['total'] == null) {
      return 0;
    }
    return int.parse(query.first['total'].toString());
  }

  // Fungsi Hapus
  Future<int> hapus(int idTransaksi) async {
    final query = await _database!
        .delete(namaTabel, where: '$id = ?', whereArgs: [idTransaksi]);
    return query;
  }

  // Fungsi Update
  Future<int> update(int idTransaksi, Map<String, dynamic> row) async {
    final query = await _database!
        .update(namaTabel, row, where: '$id = ?', whereArgs: [idTransaksi]);
    return query;
  }
}