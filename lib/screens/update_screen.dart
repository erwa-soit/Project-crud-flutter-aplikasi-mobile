import 'package:flutter/material.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';
import 'package:crud_project_pencatatan_keuangan/models/transaksi_model.dart';

class UpdateScreen extends StatefulWidget {
  final TransaksiModel transaksiMmodel;
  const UpdateScreen({Key? key, required this.transaksiMmodel})
      : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  DatabaseInstance databaseInstance = DatabaseInstance();
  TextEditingController nameController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  int _value = 1;

  @override
  void initState() {
    // Inisialisasi database
    databaseInstance.database();
    
    // Isi field dengan data lama
    nameController.text = widget.transaksiMmodel.name ?? "";
    totalController.text = widget.transaksiMmodel.total?.toString() ?? "0";
    _value = widget.transaksiMmodel.type ?? 1;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Transaksi"),
        backgroundColor: Colors.pink, // Warna pink
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nama"),
            TextField(
              controller: nameController,
            ),
            const SizedBox(height: 20),
            const Text("Tipe Transaksi"),
            ListTile(
              title: const Text("Pemasukan"),
              leading: Radio(
                  groupValue: _value,
                  value: 1,
                  onChanged: (value) {
                    setState(() {
                      _value = int.parse(value.toString());
                    });
                  }),
            ),
            ListTile(
              title: const Text("Pengeluaran"),
              leading: Radio(
                  groupValue: _value,
                  value: 2,
                  onChanged: (value) {
                    setState(() {
                      _value = int.parse(value.toString());
                    });
                  }),
            ),
            const SizedBox(height: 20),
            const Text("Total"),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number, // Keyboard angka
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    // PERBAIKAN: Ubah teks menjadi angka (Integer)
                    int totalAngka = int.tryParse(totalController.text) ?? 0;

                    await databaseInstance.update(widget.transaksiMmodel.id!, {
                      'name': nameController.text,
                      'type': _value,
                      'total': totalAngka, // Mengirim angka, bukan teks
                      'updated_at': DateTime.now().toString()
                    });
                    
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Tombol pink
                  ),
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white))),
            ),
          ],
        ),
      )),
    );
  }
}