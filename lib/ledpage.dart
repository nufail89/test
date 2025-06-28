// library my_app.homepagecontent;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// New LedScreen Class
class LedScreen extends StatefulWidget {
  const LedScreen({super.key});

  @override
  _LedScreenState createState() => _LedScreenState();
}

class _LedScreenState extends State<LedScreen> {
  // Brightness settings
  int _selectedNightBrightness = 1; // Default for night brightness
  int _selectedDayBrightness = 80; // Default for day brightness

  // Panel settings
  TextEditingController _horizontalPanelController = TextEditingController(text: '1'); // Default to 1
  TextEditingController _verticalPanelController = TextEditingController(text: '1'); // Default to 1

  // Display mode settings
  int _selectedDisplayMode = 3; // Default to 'Tampil IP'
  final Map<int, String> _displayModeOptions = {
    1: 'Tampil IP',
    2: 'Test Led',
    3: 'Tampil JWS',
  };

  @override
  void dispose() {
    _horizontalPanelController.dispose();
    _verticalPanelController.dispose();
    super.dispose();
  }

  Future<void> _kirimDataLed() async {
    final url = Uri.parse("http://192.168.4.1"); // Ensure http:// is included for a valid URI

    // Parse panel counts to integers
    final int? horizontalPanels = int.tryParse(_horizontalPanelController.text);
    final int? verticalPanels = int.tryParse(_verticalPanelController.text);

    if (horizontalPanels == null || verticalPanels == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pastikan jumlah panel diisi dengan angka yang valid.')),
        );
      }
      return;
    }

    final data = {
      'nightBrightness': _selectedNightBrightness,
      'dayBrightness': _selectedDayBrightness,
      'horizontalPanels': horizontalPanels,
      'verticalPanels': verticalPanels,
      'displayMode': _selectedDisplayMode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data LED berhasil dikirim')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal mengirim data LED. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan LED: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate brightness options for Day Brightness: 0%, 5%, 10%, 20%, ..., 100%
    List<int> dayBrightnessOptions = [];
    dayBrightnessOptions.add(0); // Add 0%
    dayBrightnessOptions.add(5);  // Add 5%
    for (int i = 1; i <= 10; i++) { // Add 10%, 20%, ..., 100%
      dayBrightnessOptions.add(i * 10);
    }
    dayBrightnessOptions = dayBrightnessOptions.toSet().toList()..sort(); // Remove duplicates and sort

    // Generate brightness options for Night Brightness: 0%, 1%, 5%, 10%, 20%, ..., 100%
    List<int> nightBrightnessOptions = [0, 1, 5]; // Specific initial values
    for (int i = 1; i <= 10; i++) { // Add 10%, 20%, ..., 100%
      if (!nightBrightnessOptions.contains(i * 10)) { // Avoid duplicating 10% if already added
        nightBrightnessOptions.add(i * 10);
      }
    }
    nightBrightnessOptions.sort(); // Sort to ensure ascending order


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kecerahan Malam
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Kecerahan Malam',
              hintText: 'Pilih tingkat kecerahan malam',
              filled: true,
              fillColor: Colors.orange.shade50,
              prefixIcon: const Icon(
                Icons.nights_stay,
                color: Colors.deepPurple,
              ),
            ),
            value: _selectedNightBrightness,
            items: nightBrightnessOptions.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text('$value%'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedNightBrightness = val!;
              });
            },
            selectedItemBuilder: (BuildContext context) {
              return nightBrightnessOptions.map((value) {
                return Text(
                  '$value%',
                  style: TextStyle(
                    color: Colors.deepPurple.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(height: 20),

          // Kecerahan Siang
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Kecerahan Siang',
              hintText: 'Pilih tingkat kecerahan siang',
              filled: true,
              fillColor: Colors.orange.shade50,
              prefixIcon: const Icon(
                Icons.wb_sunny,
                color: Colors.orange,
              ),
            ),
            value: _selectedDayBrightness,
            items: dayBrightnessOptions.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text('$value%'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDayBrightness = val!;
              });
            },
            selectedItemBuilder: (BuildContext context) {
              return dayBrightnessOptions.map((value) {
                return Text(
                  '$value%',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'Atur jumlah panel LED',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Jumlah Panel Horizontal
          TextFormField(
            controller: _horizontalPanelController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Panel Horizontal',
              hintText: 'Misal: 4',
              filled: true,
              fillColor: Colors.lightBlue.shade50,
              prefixIcon: const Icon(
                Icons.view_array,
                color: Colors.lightBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Jumlah Panel Vertikal
          TextFormField(
            controller: _verticalPanelController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Panel Vertikal',
              hintText: 'Misal: 2',
              filled: true,
              fillColor: Colors.lightBlue.shade50,
              prefixIcon: const Icon(
                Icons.view_column,
                color: Colors.lightBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // DropdownButtonFormField for Display Mode
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Mode Tampilan',
              hintText: 'Pilih mode tampilan',
              filled: true,
              fillColor: Colors.green.shade50,
              prefixIcon: const Icon(
                Icons.tv,
                color: Colors.green,
              ),
            ),
            value: _selectedDisplayMode,
            items: _displayModeOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDisplayMode = val!;
              });
            },
            selectedItemBuilder: (BuildContext context) {
              return _displayModeOptions.entries.map((entry) {
                return Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _kirimDataLed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Kirim Data LED',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}