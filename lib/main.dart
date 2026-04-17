import 'package:crud_project_pencatatan_keuangan/screens/create_screen.dart';
import 'package:crud_project_pencatatan_keuangan/db/database_instance.dart';
import 'package:crud_project_pencatatan_keuangan/screens/update_screen.dart';
import 'package:crud_project_pencatatan_keuangan/models/transaksi_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kelola Duitku",
      // TEMA PINK
      theme: ThemeData(
        primarySwatch: Colors.pink,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseInstance? databaseInstance;

  Future _refresh() async {
    setState(() {});
  }

  @override
  void initState() {
    databaseInstance = DatabaseInstance();
    initDatabase();
    super.initState();
  }

  Future initDatabase() async {
    await databaseInstance!.database();
    setState(() {});
  }

  showAlertDialog(BuildContext context, int idTransaksi) {
    Widget okButton = TextButton(
      child: const Text("Yakin"),
      onPressed: () {
        databaseInstance!.hapus(idTransaksi);
        Navigator.pop(context);
        setState(() {});
      },
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text("Peringatan !"),
      content: const Text("Anda yakin akan menghapus ?"),
      actions: [okButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Kelola Duitku"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              FutureBuilder<int>(
                  future: databaseInstance!.totalPemasukan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("-");
                    } else {
                      return Text(
                          "Total pemasukan : Rp. ${snapshot.data ?? 0}",
                          style: const TextStyle(fontWeight: FontWeight.bold));
                    }
                  }),
              const SizedBox(height: 10),
              FutureBuilder<int>(
                  future: databaseInstance!.totalPengeluaran(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("-");
                    } else {
                      return Text(
                          "Total pengeluaran : Rp. ${snapshot.data ?? 0}",
                          style: const TextStyle(fontWeight: FontWeight.bold));
                    }
                  }),
              const Divider(height: 30),
              FutureBuilder<List<TransaksiModel>>(
                  future: databaseInstance!.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(snapshot.data![index].name!),
                                  subtitle: Text("Rp. ${snapshot.data![index].total}"),
                                  leading: snapshot.data![index].type == 1
                                      ? const Icon(Icons.download, color: Colors.green)
                                      : const Icon(Icons.upload, color: Colors.red),
                                  trailing: Wrap(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpdateScreen(
                                                          transaksiMmodel: snapshot.data![index],
                                                        )))
                                                .then((value) {
                                              setState(() {});
                                            });
                                          },
                                          icon: const Icon(Icons.edit, color: Colors.grey)),
                                      IconButton(
                                          onPressed: () {
                                            showAlertDialog(context, snapshot.data![index].id!);
                                          },
                                          icon: const Icon(Icons.delete, color: Colors.red))
                                    ],
                                  ),
                                );
                              }),
                        );
                      } else {
                        return const Expanded(
                          child: Center(child: Text("Tidak ada data")),
                        );
                      }
                    }
                  })
            ],
          ),
        ),
      ),
      // TOMBOL TAMBAH DI BAWAH
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const CreateScreen()))
              .then((value) {
            setState(() {});
          });
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}