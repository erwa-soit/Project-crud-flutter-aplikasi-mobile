import 'package:flutter/material.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  DatabaseInstance databaseInstance = DatabaseInstance();
  TextEditingController nameController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  int _value = 1;

  @override
  void initState() {
    databaseInstance.database();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Transaksi")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Transaksi"),
              TextField(controller: nameController),
              const SizedBox(height: 20),
              const Text("Tipe"),
              RadioListTile(
                title: const Text("Pemasukan"),
                value: 1,
                groupValue: _value,
                onChanged: (value) => setState(() => _value = value as int),
              ),
              RadioListTile(
                title: const Text("Pengeluaran"),
                value: 2,
                groupValue: _value,
                onChanged: (value) => setState(() => _value = value as int),
              ),
              const SizedBox(height: 20),
              const Text("Total"),
              TextField(
                controller: totalController,
                keyboardType: TextInputType.number, // Munculkan keyboard angka
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      // PERBAIKAN: Harus di-parse ke INT
                      int totalInput = int.tryParse(totalController.text) ?? 0;
                      
                      await databaseInstance.insert({
                        'name': nameController.text,
                        'type': _value,
                        'total': totalInput,
                        'created_at': DateTime.now().toString(),
                        'updated_at': DateTime.now().toString(),
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    child: const Text("Simpan", style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}