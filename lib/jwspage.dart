// library my_app.jwspage;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart'; // Import for time zone offset

class JwsScreen extends StatefulWidget {
  const JwsScreen({super.key});

  @override
  _JwsScreenState createState() => _JwsScreenState();
}

class _JwsScreenState extends State<JwsScreen> {
  int _selectedKoreksi = 0;
  int _selectedMetodeKitab = 1; // Default to Irsyadul Murid
  int _selectedTipeTempat = 1; // Default to Masjid
  double _selectedInkhifadIsya = -17.8; // Default for Inkhifad Isya'
  double _selectedInkhifadShubuh = -19.8; // Default for Inkhifad Shubuh

  final TextEditingController _namaMasjid = TextEditingController();
  final TextEditingController _textAlamat = TextEditingController();
  final TextEditingController _info1Controller = TextEditingController();
  final TextEditingController _info2Controller = TextEditingController();
  final TextEditingController _info3Controller = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _altitudeController =
      TextEditingController(); // Controller for altitude
  final TextEditingController _timezoneController =
      TextEditingController(); // Controller for timezone (display only)

  // Define default latitude and longitude for display/initial values
  final double _defaultLatitude = -7.5;
  final double _defaultLongitude = 112.9;
  final double _defaultAltitude = 10.0;
  final double _defaultTimeZoneDisplay = 7.0; // For displaying default info

  // New controllers for Ihtiyat inputs with _iht prefix
  final TextEditingController _ihtDhuhurController = TextEditingController(
    text: '2',
  );
  final TextEditingController _ihtAsharController = TextEditingController(
    text: '2',
  );
  final TextEditingController _ihtMaghribController = TextEditingController(
    text: '2',
  );
  final TextEditingController _ihtIsyaController = TextEditingController(
    text: '2',
  );
  final TextEditingController _ihtShubuhController = TextEditingController(
    text: '2',
  );
  final TextEditingController _lamaSholatController = TextEditingController(
    text: '10',
  );

  @override
  void initState() {
    super.initState();
    _latitudeController.text = _defaultLatitude.toStringAsFixed(6);
    _longitudeController.text = _defaultLongitude.toStringAsFixed(6);
    _altitudeController.text = _defaultAltitude.toStringAsFixed(2);
    // Initialize timezone controller with a general GMT offset placeholder
    _timezoneController.text = 'Loading Timezone...';

    // Automatically determine position and timezone on screen load
    _determinePosition();
  }

  void _showPrayerTimes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrayerTimesPage()),
    );
  }

  Future<void> _kirimData() async {
    final url = Uri.parse('http://192.168.4.1/setjws');

    // Get the numerical timezone offset from the device's current time
    final int currentUtcOffset = DateTime.now().timeZoneOffset.inHours.toInt();

    final data = {
      'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
      'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
      'altitude': double.tryParse(_altitudeController.text) ?? 0.0,
      'timezone': currentUtcOffset, // Send the numerical GMT offset
      'metode_kitab': _selectedMetodeKitab,
      'tipe_tempat': _selectedTipeTempat,
      'koreksi_hari': _selectedKoreksi,

      'inkhifad_isya': _selectedInkhifadIsya,
      'inkhifad_shubuh': _selectedInkhifadShubuh,
      // New Ihtiyat data
      'ihtiyat_dhuhur': int.tryParse(_ihtDhuhurController.text) ?? 0,
      'ihtiyat_ashar': int.tryParse(_ihtAsharController.text) ?? 0,
      'ihtiyat_maghrib': int.tryParse(_ihtMaghribController.text) ?? 0,
      'ihtiyat_isya': int.tryParse(_ihtIsyaController.text) ?? 0,
      'ihtiyat_shubuh': int.tryParse(_ihtShubuhController.text) ?? 0,
      'lama_sholat': int.tryParse(_lamaSholatController.text) ?? 0,

      //Text Running
      'textAlamat': _textAlamat.text,
      'namaMasjid': _namaMasjid.text,
      'informasi1': _info1Controller.text,
      'informasi2': _info2Controller.text,
      'informasi3': _info3Controller.text,
    };
    //cek data json yang akan dikirim
    print('Data yang akan dikirim:');
    print(jsonEncode(data)); // Menampilkan data dalam format JSON

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data JWS berhasil dikirim')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal mengirim data JWS. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan JWS: $e')));
      }
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Layanan lokasi dinonaktifkan. Mohon aktifkan GPS Anda.',
            ),
          ),
        );
      }
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin lokasi ditolak. Tidak dapat mengambil koordinat.',
              ),
            ),
          );
        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen. Silakan buka pengaturan aplikasi untuk mengizinkan.',
            ),
          ),
        );
      }
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 100),
      );

      // Get the local timezone name (e.g., "Asia/Jakarta")
      String currentTimeZoneName = await FlutterTimezone.getLocalTimezone();

      // Get the numerical UTC offset in hours from the device's current time
      final double currentUtcOffset = DateTime.now().timeZoneOffset.inHours
          .toDouble();

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _altitudeController.text = position.altitude.toStringAsFixed(2);
          // Display both the IANA name and the GMT offset for clarity
          _timezoneController.text =
              '$currentTimeZoneName (GMT${currentUtcOffset.toInt() >= 0 ? '+' : ''}${currentUtcOffset.toInt()})';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
        // Fallback or clear timezone if location fails
        setState(() {
          _timezoneController.text = 'Error fetching timezone';
        });
      }
    }
  }

  @override
  void dispose() {
    _namaMasjid.dispose();
    _textAlamat.dispose();
    _info1Controller.dispose();
    _info2Controller.dispose();
    _info3Controller.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _altitudeController.dispose();
    _timezoneController.dispose();
    _ihtDhuhurController.dispose();
    _ihtAsharController.dispose();
    _ihtMaghribController.dispose();
    _ihtIsyaController.dispose();
    _ihtShubuhController.dispose();
    _lamaSholatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Metode Kitab',
                    hintText: 'Pilih metode kitab',
                    filled: true,
                    fillColor: Colors.green.shade50,
                    isDense: true,
                  ),
                  value: _selectedMetodeKitab,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Irsyadul Murid')),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Durusul Falakiyah'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedMetodeKitab = val!;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return const [
                      Text(
                        'Irsyadul Murid',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Durusul Falakiyah',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ];
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tipe Tempat',
                    hintText: 'Pilih tipe tempat',
                    filled: true,
                    fillColor: Colors.orange.shade50,
                    isDense: true,
                  ),
                  value: _selectedTipeTempat,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Masjid')),
                    DropdownMenuItem(value: 2, child: Text('Musholla')),
                    DropdownMenuItem(value: 3, child: Text('Rumah')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedTipeTempat = val!;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return const [
                      Text(
                        'Masjid',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Musholla',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rumah',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- New Row for Inkhifad Isya' and Shubuh ---
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<double>(
                  decoration: InputDecoration(
                    // Removed prefixIcon for more space
                    labelText: "Inkhifad Isya'",
                    hintText: "Isya'", // Shorter hint text
                    filled: true,
                    fillColor: Colors.red.shade50,
                    isDense: true, // Make it more compact
                  ),
                  value: _selectedInkhifadIsya,
                  items: const [
                    DropdownMenuItem(value: -17.0, child: Text('-17.0°')),
                    DropdownMenuItem(value: -17.5, child: Text('-17.5°')),
                    DropdownMenuItem(value: -17.8, child: Text('-17.8°')),
                    DropdownMenuItem(value: -18.0, child: Text('-18.0°')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedInkhifadIsya = val!;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return const [
                      Text(
                        '-17.0°',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-17.5°',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-17.8°',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-18.0°',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ];
                  },
                ),
              ),
              const SizedBox(width: 8), // Reduced space
              Expanded(
                child: DropdownButtonFormField<double>(
                  decoration: InputDecoration(
                    // Removed prefixIcon for more space
                    labelText: "Inkhifad Shubuh",
                    hintText: "Shubuh", // Shorter hint text
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    isDense: true, // Make it more compact
                  ),
                  value: _selectedInkhifadShubuh,
                  items: const [
                    DropdownMenuItem(value: -19.0, child: Text('-19.0°')),
                    DropdownMenuItem(value: -19.5, child: Text('-19.5°')),
                    DropdownMenuItem(value: -19.8, child: Text('-19.8°')),
                    DropdownMenuItem(value: -20.0, child: Text('-20.0°')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedInkhifadShubuh = val!;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return const [
                      Text(
                        '-19.0°',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 47, 122),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-19.5°',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-19.8°',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-20.0°',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ];
                  },
                ),
              ),
              // const SizedBox(width: 8), // Reduced space
            ],
          ),
          const SizedBox(width: 8), // Reduced space
          const SizedBox(height: 15),

          // --- Latitude and Longitude with Refresh Button ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Lintang',
                    hintText: 'Isi Lintang',
                    prefixIcon: Icon(Icons.location_on, color: Colors.purple),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Bujur',
                    hintText: 'Isi Bujur',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: Colors.purple,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 2), // Space between input and button
            ],
          ),
          const SizedBox(width: 8), // Reduced space
          const SizedBox(height: 15),
          // --- Default Latitude and Longitude Information ---
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _altitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Tinggi Tempat (Meter)',
                    hintText: 'Isi Tinggi Tempat',
                    prefixIcon: Icon(Icons.landscape, color: Colors.brown),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _timezoneController,
                  decoration: const InputDecoration(
                    labelText: 'Timezone',
                    hintText: 'Zona Waktu',
                    prefixIcon: Icon(Icons.access_time, color: Colors.teal),
                  ),
                  readOnly:
                      true, // Making it read-only as it's automatically fetched
                  enabled: false, // Disabling direct input
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.purple),
                onPressed: _determinePosition,
                tooltip: 'Ambil lokasi saat ini (GPS)',
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lokasi terakhir JWS: Lintang ${_defaultLatitude.toStringAsFixed(6)}, Bujur ${_defaultLongitude.toStringAsFixed(6)}, Tinggi Tempat ${_defaultAltitude.toStringAsFixed(2)}, TZ GMT${_defaultTimeZoneDisplay.toInt() >= 0 ? '+' : ''}${_defaultTimeZoneDisplay.toInt()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 15), // Spacer before new fields

          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Koreksi Hijriyah',
              hintText: 'Pilih koreksi hari',
              filled: true,
              fillColor: Colors.blue.shade50,
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
            ),
            value: _selectedKoreksi,
            items: const [
              DropdownMenuItem(value: -1, child: Text('-1 Hari')),
              DropdownMenuItem(value: 0, child: Text('0 Hari')),
              DropdownMenuItem(value: 1, child: Text('1 Hari')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedKoreksi = val!;
              });
            },
            selectedItemBuilder: (BuildContext context) {
              return [-1, 0, 1].map((int val) {
                return Text(
                  '$val Hari',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 4), // Reduced space
          const SizedBox(height: 20),
          // New Ihtiyat Inputs
          const Text(
            'Ihtiyat (satuan menit):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ihtDhuhurController,
                  decoration: const InputDecoration(
                    labelText: 'Dhuhur',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ihtAsharController,
                  decoration: const InputDecoration(
                    labelText: 'Ashar',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ihtMaghribController,
                  decoration: const InputDecoration(
                    labelText: 'Maghrib',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ihtIsyaController,
                  decoration: const InputDecoration(
                    labelText: 'Isya\'',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ihtShubuhController,
                  decoration: const InputDecoration(
                    labelText: 'Shubuh',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _lamaSholatController,
                  decoration: const InputDecoration(
                    labelText: 'Lama Sholat',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ---
          const Text(
            'Running Text',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          // TextField (Text Area) Nama Masjid
          TextField(
            controller: _namaMasjid,
            decoration: const InputDecoration(
              labelText: 'Nama Masjid',
              hintText: 'Masukkan Nama Masjid',
              prefixIcon: Icon(Icons.info_outline),
            ),
            maxLines: 1,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 15),
          // TextField (Text Area) Alamat
          TextField(
            controller: _textAlamat,
            decoration: const InputDecoration(
              labelText: 'Alamat',
              hintText: 'Masukkan Alamat',
              prefixIcon: Icon(Icons.info_outline),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 15),
          // TextField (Text Area) yang lebih cantik untuk Informasi 1
          TextField(
            controller: _info1Controller,
            decoration: const InputDecoration(
              labelText: 'Informasi 1',
              hintText: 'Masukkan informasi pertama',
              prefixIcon: Icon(Icons.info_outline),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 15),
          // TextField (Text Area) yang lebih cantik untuk Informasi 2
          TextField(
            controller: _info2Controller,
            decoration: const InputDecoration(
              labelText: 'Informasi 2',
              hintText: 'Masukkan informasi kedua',
              prefixIcon: Icon(Icons.info),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _info3Controller,
            decoration: const InputDecoration(
              labelText: 'Informasi 3',
              hintText: 'Masukkan informasi kedua',
              prefixIcon: Icon(Icons.info),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: _kirimData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Kirim Data JWS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          // Tombol "Lihat Waktu Sholat"
          ElevatedButton(
            onPressed: _showPrayerTimes,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Different color for distinction
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Lihat Waktu Sholat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15), // Spacing between buttons
        ],
      ),
    );
  
  }
}

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  final Map<String, String> prayerTimes = const {
    'Dzuhur': '11:36',
    'Ashar': '14:44',
    'Maghrib': '17:35',
    'Isya\'': '18:48',
    'Shubuh': '03:58',
    'Thulu\'': '05:23',
    'Dluha': '06:33',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waktu Sholat'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Informasi Waktu Sholat:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.grey.shade400),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1.0),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Colors.lightGreen),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Waktu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Jam',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ...prayerTimes.entries.map((entry) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
