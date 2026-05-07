import 'package:flutter/material.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';

class CreateScreen extends StatefulWidget {
  final int type; // 1 untuk Pemasukan, 2 untuk Pengeluaran
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
        // Warna Pink Soft sesuai Dashboard
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
            const Text("Keterangan", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "", // Kosong tanpa contoh
                filled: true,
                fillColor: Colors.pink.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text("Jumlah Saldo", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "Rp ",
                filled: true,
                fillColor: Colors.pink.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // TOMBOL SIMPAN PINK SOFT
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  // Bersihkan input dari karakter non-angka (Rp, titik, spasi)
                  String cleanTotal = totalController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  
                  // Validasi Input Kosong
                  if (nameController.text.isEmpty || cleanTotal.isEmpty) {
                    _showSnackBar("Isi keterangan dan jumlah dulu ya!", Colors.orange);
                    return;
                  }

                  int nominalInput = int.parse(cleanTotal);

                  // --- LOGIKA CEK SALDO (REVISI DOSEN) ---
                  if (widget.type == 2) { // Jika sedang mencatat Pengeluaran
                    int totalMasuk = await databaseInstance.totalPemasukan();
                    int totalKeluar = await databaseInstance.totalPengeluaran();
                    int sisaSaldo = totalMasuk - totalKeluar;

                    if (nominalInput > sisaSaldo) {
                      // Alert merah hanya muncul di sini saat saldo tidak cukup
                      _showSnackBar("Transaksi Gagal! Saldo anda tidak cukup", Colors.red.shade700);
                      return; // Stop proses simpan
                    }
                  }

                  try {
                    // Simpan ke Database
                    await databaseInstance.insert({
                      'name': nameController.text,
                      'type': widget.type,
                      'total': nominalInput,
                      'created_at': DateTime.now().toString(),
                      'updated_at': DateTime.now().toString(),
                    });

                    if (mounted) {
                      _showSnackBar("Data berhasil disimpan", Colors.pink.shade400);
                      Navigator.pop(context, true); // Kembali ke dashboard dengan refresh
                    }
                  } catch (e) {
                    _showSnackBar("Terjadi kesalahan: $e", Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100, // Pink Soft
                  foregroundColor: Colors.pink.shade900,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("SIMPAN TRANSAKSI", 
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Helper untuk memunculkan pesan SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}