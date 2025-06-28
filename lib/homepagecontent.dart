// library my_app.homepagecontent;

import 'package:flutter/material.dart';
import 'package:setjws/globals.dart' as globals;

/// Widget khusus untuk konten halaman Home
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // Controller untuk TextField, inisialisasi dengan nilai IP_ESP saat ini
  late TextEditingController _ipController;
  final TextEditingController _ipAddress = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nilai global IP_ESP
    _ipController = TextEditingController(text: globals.IP_ESP);
  }

  @override
  void dispose() {
    _ipController.dispose(); // Pastikan controller di-dispose
    super.dispose();
  }

  void _saveIpAddress() {
    setState(() {
      // Perbarui nilai global IP_ESP dengan nilai dari TextField
      globals.IP_ESP = _ipAddress.text;
    });
    // Tampilkan pesan atau konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IP ESP disimpan: ${globals.IP_ESP}')),
    );
    // print('IP_ESP telah diubah menjadi: ${globals.IP_ESP}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Atur Alamat IP ESP:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ipAddress,
            decoration: const InputDecoration(
              labelText: 'IP Address LED',
              hintText: 'Misal: 192.168.4.1',
              prefixIcon: Icon(Icons.router),
            ),
            keyboardType: TextInputType.number, // Memudahkan input IP
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _saveIpAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // Warna tombol berbeda
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
            ),
            child: const Text(
              'SIMPAN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // Tampilkan nilai IP_ESP saat ini
          Text(
            'IP ESP Saat Ini: ${globals.IP_ESP}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
