import 'package:flutter/material.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';

class CreateScreen extends StatefulWidget {
  final int type;
  const CreateScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  DatabaseInstance databaseInstance = DatabaseInstance();
  TextEditingController nameController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.type == 1 ? "Tambah Pemasukan" : "Tambah Pengeluaran",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.pink.shade50,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.pink.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.pink.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 25),
            const Text("Jumlah Saldo", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "Rp ", // Ini hanya hiasan, user cukup ketik angka
                filled: true,
                fillColor: Colors.pink.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  // --- LOGIKA PEMBERSIH TERPAKSA ---
                  // Menghapus Rp, spasi, titik, atau koma agar tersisa angka saja
                  String rawValue = totalController.text;
                  String cleanValue = rawValue.replaceAll(RegExp(r'[^0-9]'), '');

                  if (nameController.text.isEmpty || cleanValue.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Isi Keterangan dan Jumlah dulu!")),
                    );
                    return;
                  }

                  try {
                    // Masukkan ke database
                    await databaseInstance.insert({
                      'name': nameController.text,
                      'type': widget.type,
                      'total': int.parse(cleanValue), // Konversi ke angka murni
                      'created_at': DateTime.now().toString(),
                      'updated_at': DateTime.now().toString(),
                    });

                    // Tutup halaman dan kirim sinyal 'true' untuk refresh data
                    if (mounted) Navigator.pop(context, true);
                  } catch (e) {
                    // Jika masih gagal, munculkan pesan errornya apa
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal Simpan: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("SIMPAN TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}