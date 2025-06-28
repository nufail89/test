import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Untuk Timer

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  // Variabel untuk menyimpan waktu perangkat saat ini
  DateTime _deviceCurrentTime = DateTime.now();
  // Variabel untuk menyimpan waktu yang disinkronkan dari ESP
  // Awalnya null atau waktu default sampai disinkronkan
  DateTime? _espSynchronizedTime;
  // Pesan status untuk umpan balik pengguna
  String _syncStatusMessage = 'Tekan tombol Sinkronkan Waktu untuk mengatur waktu ESP.';

  // Inisialisasi Timer untuk memperbarui waktu perangkat setiap detik
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Memulai timer untuk memperbarui waktu perangkat setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _deviceCurrentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // Memastikan timer dibatalkan saat widget dihilangkan untuk mencegah kebocoran memori
    _timer.cancel();
    super.dispose();
  }

  // Fungsi untuk mengirim data waktu ke ESP
  Future<void> _syncTimeWithESP() async {
    // URL endpoint ESP Anda (ganti sesuai dengan IP ESP Anda)
    final url = Uri.parse("http://192.168.4.1/sync_time"); // Contoh endpoint untuk sinkronisasi waktu

    // Ambil waktu saat ini dari perangkat
    final now = DateTime.now();

    // Siapkan data dalam format JSON
    final data = {
      'tahun': now.year,
      'bulan': now.month,
      'tanggal': now.day,
      'jam': now.hour,
      'menit': now.minute,
      'detik': now.second,
    };
    String jsonBody = jsonEncode(data); // Encode fullData
    print('Mengirim JSON: $jsonBody');
    setState(() {
      _syncStatusMessage = 'Mengirim data waktu ke ESP...';
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _espSynchronizedTime = now; // Asumsikan ESP berhasil disinkronkan dengan waktu ini
            _syncStatusMessage = 'Waktu berhasil disinkronkan dengan ESP!';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Waktu berhasil disinkronkan dengan ESP')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _syncStatusMessage = 'Gagal sinkronisasi waktu. Status: ${response.statusCode}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal sinkronisasi waktu. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncStatusMessage = 'Terjadi kesalahan saat sinkronisasi waktu: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan sinkronisasi: $e')));
      }
    }
  }

  // Helper untuk format waktu
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informasi Waktu di Perangkat
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waktu Saat Ini di Perangkat:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatDateTime(_deviceCurrentTime),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Tombol Sinkronkan Waktu
          ElevatedButton.icon(
            onPressed: _syncTimeWithESP,
            icon: const Icon(Icons.sync, size: 24),
            label: const Text(
              'Sinkronkan Waktu dengan ESP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // Warna tombol berbeda
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
            ),
          ),
          const SizedBox(height: 30),

          // Informasi Waktu dari ESP yang Telah Disinkronkan
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            color: Colors.lightGreen.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waktu Terakhir Disinkronkan di ESP:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _espSynchronizedTime != null
                        ? _formatDateTime(_espSynchronizedTime!)
                        : 'Belum ada sinkronisasi',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _espSynchronizedTime != null ? Colors.green.shade800 : Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _syncStatusMessage,
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
