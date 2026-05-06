import 'package:flutter/material.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';
import 'package:crud_project_pencatatan_keuangan/models/transaksi_model.dart';

class UpdateScreen extends StatefulWidget {
  final TransaksiModel transaksiMmodel;
  const UpdateScreen({Key? key, required this.transaksiMmodel}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  DatabaseInstance databaseInstance = DatabaseInstance();
  TextEditingController nameController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  void initState() {
    // Memasukkan data lama ke TextField saat halaman dibuka
    nameController.text = widget.transaksiMmodel.name ?? "";
    totalController.text = widget.transaksiMmodel.total.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul di sebelah kiri sesuai permintaan
        title: const Text("Edit Transaksi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false, 
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.pink.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Jumlah Uang (Angka Saja)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "Rp ",
                filled: true,
                fillColor: Colors.pink.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  // MENGHAPUS karakter selain angka agar database tidak error
                  String cleanTotal = totalController.text.replaceAll(RegExp(r'[^0-9]'), '');

                  if (nameController.text.isNotEmpty && cleanTotal.isNotEmpty) {
                    // PASTIKAN di DatabaseInstance nama fungsinya adalah 'update'
                    // Jika di file DB kamu namanya 'updateTransaksi', ganti tulisan di bawah ini
                    await databaseInstance.update(widget.transaksiMmodel.id!, {
                      'name': nameController.text,
                      'total': int.parse(cleanTotal),
                      'updated_at': DateTime.now().toString(),
                    });
                    
                    // Kembali ke layar sebelumnya
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Semua kolom harus diisi!"))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}