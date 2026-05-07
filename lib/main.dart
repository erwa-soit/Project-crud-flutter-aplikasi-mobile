import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:crud_project_pencatatan_keuangan/screens/create_screen.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';
import 'package:crud_project_pencatatan_keuangan/screens/update_screen.dart';
import 'package:crud_project_pencatatan_keuangan/models/transaksi_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pencatatan Keuangan",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade50,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            color: Colors.black87, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 60,
          indicatorColor: Colors.pink.shade100.withOpacity(0.5),
          indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final DatabaseInstance databaseInstance = DatabaseInstance();

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      DashboardPage(databaseInstance: databaseInstance),
      ListTransaksiPage(databaseInstance: databaseInstance, type: 1),
      ListTransaksiPage(databaseInstance: databaseInstance, type: 2),
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded), label: 'Pemasukan'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag_rounded), label: 'Pengeluaran'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 
          ? null 
          : SizedBox(
              height: 45,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => CreateScreen(type: _currentIndex)))
                      .then((value) => setState(() {}));
                },
                backgroundColor: Colors.pink.shade300, 
                foregroundColor: Colors.white,
                elevation: 1,
                icon: Icon(_currentIndex == 1 ? Icons.add_rounded : Icons.remove_rounded, size: 18),
                label: Text(_currentIndex == 1 ? "Tambah Masuk" : "Tambah Keluar", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
    );
  }
}

// --- HALAMAN DASHBOARD ---
class DashboardPage extends StatefulWidget {
  final DatabaseInstance databaseInstance;
  const DashboardPage({Key? key, required this.databaseInstance}) : super(key: key);
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Pencatatan Keuangan")),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              FutureBuilder<List<int>>(
                future: Future.wait([
                  widget.databaseInstance.totalPemasukan(),
                  widget.databaseInstance.totalPengeluaran(),
                ]),
                builder: (context, snapshot) {
                  int masuk = snapshot.data?[0] ?? 0;
                  int keluar = snapshot.data?[1] ?? 0;
                  int saldo = masuk - keluar;
                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildMiniStat("Pemasukan", masuk, Icons.arrow_downward_rounded, Colors.green),
                          const SizedBox(width: 12),
                          _buildMiniStat("Pengeluaran", keluar, Icons.arrow_upward_rounded, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // --- BAGIAN SISA SALDO DI DASHBOARD ---
// Cari bagian Card Saldo di DashboardPage (main.dart)
Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Padding vertikal dikecilkan
  decoration: BoxDecoration(
    color: Colors.pink.shade50, // Pink Soft selaras
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.pink.shade100),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min, // Agar kotak tidak besar (ramping)
    children: [
      // ANGKA DI ATAS
      Text(
        saldo < 0 ? "Rp 0" : "Rp ${saldo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
        style: TextStyle(
          color: saldo < 0 ? Colors.red.shade700 : Colors.pink.shade800,
          fontSize: 22, // Ukuran angka pas
          fontWeight: FontWeight.bold
        ),
      ),
      const SizedBox(height: 4),
      // TEKS DI BAWAH
      Text(
        saldo < 0 ? "Saldo Anda Tidak Cukup" : "Sisa Saldo Anda",
        style: TextStyle(
          color: saldo < 0 ? Colors.red.shade700 : Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w500
        ),
      ),
    ],
  ),
),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text("Transaksi Terakhir", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              FutureBuilder<List<TransaksiModel>>(
                future: widget.databaseInstance.getAll(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Belum ada transaksi")));
                  }
                  var recentData = snapshot.data!.take(5).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentData.length,
                    itemBuilder: (context, index) {
                      var item = recentData[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.type == 1 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            child: Icon(item.type == 1 ? Icons.south_west_rounded : Icons.north_east_rounded, color: item.type == 1 ? Colors.green : Colors.red, size: 18),
                          ),
                          title: Text(item.name!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          trailing: Text(
                            "Rp ${item.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}", 
                            style: TextStyle(color: item.type == 1 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String title, int amount, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            Text("Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}", 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN DAFTAR TRANSAKSI (DENGAN POP-UP HAPUS) ---
class ListTransaksiPage extends StatefulWidget {
  final DatabaseInstance databaseInstance;
  final int type;
  const ListTransaksiPage({Key? key, required this.databaseInstance, required this.type}) : super(key: key);
  @override
  State<ListTransaksiPage> createState() => _ListTransaksiPageState();
}

class _ListTransaksiPageState extends State<ListTransaksiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.type == 1 ? "Daftar Pemasukan" : "Daftar Pengeluaran")),
      body: FutureBuilder<List<TransaksiModel>>(
        future: widget.databaseInstance.getAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.where((item) => item.type == widget.type).toList();
          if (data.isEmpty) return const Center(child: Text("Data masih kosong"));
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.pink.shade50)),
                child: ListTile(
                  title: Text(item.name!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rp ${item.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue), 
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateScreen(transaksiMmodel: item))).then((value) => setState(() {}))
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red), 
                        onPressed: () {
                          // POP-UP KONFIRMASI HAPUS
                         
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    // KUNCINYA: Atur insetPadding agar kotak mengecil secara horizontal
    insetPadding: const EdgeInsets.symmetric(horizontal: 100), 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    contentPadding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
    title: const Center(
      child: Text("Hapus?", 
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ),
    content: const Text(
      "Yakin mau hapus data ini?",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14),
    ),
    actionsAlignment: MainAxisAlignment.spaceEvenly, // Tombol berjejer rapi
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
      ),
      TextButton(
        onPressed: () async {
          await widget.databaseInstance.hapus(item.id!);
          Navigator.pop(context);
          setState(() {});
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil dihapus"), behavior: SnackBarBehavior.floating),
          );
        },
        child: const Text("Hapus", 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    ],
  ),
);
                        }
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}