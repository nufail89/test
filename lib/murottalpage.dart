// lib/screens/murottal_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class MurottalScreen extends StatefulWidget {
  const MurottalScreen({super.key});

  @override
  _MurottalScreenState createState() => _MurottalScreenState();
}

class _MurottalScreenState extends State<MurottalScreen> {
  // Variabel untuk status saklar DF Mini Player
  bool _dfMiniPlayerEnabled = false; // Default: OFF

  // Kunci untuk menyimpan data di SharedPreferences
  static const String _murottalDataKey = 'murottal_data';

  // Inisialisasi data jadwal murottal
  final List<Map<String, dynamic>> _data = [
    {
      'waktu': 'Dhuhur',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Asar',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Maghrib',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Isya\'',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Shubuh',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Jum\'at',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Asar Kamis',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
    {
      'waktu': 'Maghrib Kamis',
      'kodeController': TextEditingController(text: ''),
      'durasiController': TextEditingController(text: ''),
      'onOff': false
    },
  ];

  final String espUrl = 'http://192.168.1.100/data';

  @override
  void initState() {
    super.initState();
    _loadDataFromSharedPreferences(); // Muat data saat initState
  }

  @override
  void dispose() {
    for (var item in _data) {
      item['kodeController'].dispose();
      item['durasiController'].dispose();
    }
    super.dispose();
  }

  // Fungsi untuk memuat data dari SharedPreferences
  Future<void> _loadDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_murottalDataKey);

    if (savedData != null) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(savedData);
        setState(() {
          _dfMiniPlayerEnabled = decodedData['dfPlayer'] ?? false;

          final List<dynamic> jadwalMurottal = decodedData['jadwalMurottal'] ?? [];
          for (int i = 0; i < jadwalMurottal.length; i++) {
            if (i < _data.length) { // Pastikan indeks tidak keluar batas
              _data[i]['kodeController'].text = jadwalMurottal[i]['kode'] ?? '';
              _data[i]['durasiController'].text = jadwalMurottal[i]['durasi'] ?? '';
              _data[i]['onOff'] = jadwalMurottal[i]['onOff'] ?? false;
            }
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data jadwal murottal berhasil dimuat!'), duration: Duration(seconds: 2)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data jadwal: $e'), backgroundColor: Colors.red, duration: Duration(seconds: 3)),
          );
        }
        print('Error decoding saved data: $e');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data jadwal murottal tersimpan.'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  // Fungsi untuk mengirim data ke ESP dan menyimpannya ke SharedPreferences
  Future<void> _sendDataToESP() async {
    List<Map<String, dynamic>> dataToSend = _data.map((item) {
      return {
        'waktu': item['waktu'],
        'kode': item['kodeController'].text,
        'durasi': item['durasiController'].text,
        'onOff': item['onOff'],
      };
    }).toList();

    // Tambahkan status DF Mini Player ke data yang akan dikirim
    Map<String, dynamic> fullData = {
      'dfPlayer': _dfMiniPlayerEnabled, // Status saklar
      'jadwalMurottal': dataToSend, // Data jadwal yang sudah ada
    };

    String jsonBody = jsonEncode(fullData); // Encode fullData
    print('Mengirim JSON: $jsonBody');

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengirim data...'), duration: Duration(seconds: 2)),
    );

    try {
      final response = await http.post(
        Uri.parse(espUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );

      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200) {
        // Data berhasil dikirim ke ESP, sekarang simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_murottalDataKey, jsonBody); // Simpan JSON string

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dikirim & disimpan!'), backgroundColor: Colors.green),
          );
        }
        print('Respon dari ESP: ${response.body}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim data: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
        print('Gagal mengirim data. Status: ${response.statusCode}');
        print('Respon error: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
      print('Terjadi kesalahan saat mengirim data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- SAKLAR DF MINI PLAYER ---
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0), // Jarak di bawah saklar
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar teks dan saklar terpisah
                  children: [
                    Text(
                      'Setting DF Mini Player',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Switch.adaptive( // Switch dengan animasi saklar
                      value: _dfMiniPlayerEnabled,
                      onChanged: (bool newValue) {
                        setState(() {
                          _dfMiniPlayerEnabled = newValue;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.secondary, // Warna saat aktif
                      inactiveThumbColor: Colors.grey, // Warna tombol saat tidak aktif
                      inactiveTrackColor: Colors.grey.shade300, // Warna track saat tidak aktif
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- AKHIR SAKLAR DF MINI PLAYER ---

          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 10.0,
                  dataRowHeight: 50.0,
                  headingRowHeight: 50.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return Theme.of(context).primaryColor.withOpacity(0.9);
                    },
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).primaryColor.withOpacity(0.2);
                      }
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade50;
                      }
                      return null;
                    },
                  ),
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Waktu',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Kode',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Durasi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'On/Off',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                  ],
                  rows: _data.map<DataRow>((data) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              data['waktu']!,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              controller: data['kodeController'],
                              keyboardType: TextInputType.text,
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLength: 2,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                                border: const UnderlineInputBorder(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                                ),
                                filled: false,
                                hintText: '',
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              controller: data['durasiController'],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLength: 2,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                                border: const UnderlineInputBorder(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                                ),
                                filled: false,
                                hintText: '',
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 40,
                            child: Align(
                              alignment: Alignment.center,
                              child: Checkbox(
                                value: data['onOff'],
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    data['onOff'] = newValue!;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendDataToESP,
              icon: const Icon(Icons.send),
              label: const Text(
                'Kirim Data Jadwal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
