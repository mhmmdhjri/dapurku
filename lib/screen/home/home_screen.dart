import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_generator/model/history_model.dart';
import 'package:schedule_generator/network/gemini_service.dart';
import 'package:schedule_generator/screen/history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _foods = [];
  final TextEditingController _foodController = TextEditingController();
  String? errorMessage;

  List<String> bahan = [];
  List<String> langkah = [];



Future<void> generateRecipe() async {
  if (_foodController.text.isEmpty) return;

  setState(() {
    _isLoading = true;
    errorMessage = null;
    _foods.clear();
    _foods.add({
      'nama_makanan': _foodController.text,
      'bahan': [],
      'langkah': [],
    });
    _foodController.clear();
  });

  try {
    final result = await GeminiServices.generateRecipe(_foods);
    
    if (result.containsKey('error')) {
      setState(() {
        _isLoading = false;
        errorMessage = result['error'];
      });
      return;
    }

    setState(() {
      bahan = List<String>.from(result['bahan'] ?? []);
      langkah = List<String>.from(result['langkah'] ?? []);
      _isLoading = false;
    });


    final box = Hive.box('historyBox');
    final history = HistoryModel(
      namaMakanan: result['nama_makanan'],
      bahan: List<String>.from(result['bahan'] ?? []),
      langkah: List<String>.from(result['langkah'] ?? []),
    );
    box.add(history.toMap());

  } catch (e) {
    setState(() {
      _isLoading = false;
      errorMessage = 'Gagal menghasilkan resep\n$e';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
     appBar: AppBar(
        title: const Text('Recipe Generator'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
           color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              
              TextField(
                controller: _foodController,
                decoration: InputDecoration(
                  hintText: 'Nama Makanan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.orange.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : generateRecipe,
                label: Text(
                  _isLoading ? 'Generating ...' : 'Generate Recipe',
                  style: const TextStyle(color: Colors.white),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                        ),
                      )
                    : const Icon(Icons.schedule, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ),
              
              const SizedBox(height: 16),
             if (bahan.isNotEmpty || langkah.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Center(
        child: Text(
          _foods.isNotEmpty ? _foods.first['nama_makanan'] : '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      const SizedBox(height: 16), 


      _buildGlassCard("Bahan", bahan),
      const SizedBox(height: 16),


      _buildGlassCard("Langkah", langkah),
    ],
  ),

              
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  },
  backgroundColor: Colors.orange, 
  shape: const CircleBorder(), 
  child: const Icon(Icons.history, color: Colors.white),
),

    );
  }

  Widget _buildGlassCard(String title, List<String> items) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Text("- $item", style: const TextStyle(color: Colors.black))),
            ],
          ),
        ),
      ),
    );
  }
}