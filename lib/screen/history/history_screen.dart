import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:schedule_generator/model/history_model.dart';
import 'package:schedule_generator/screen/history/history_detail_screen.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box('historyBox');
  }

  void deleteHistory(int index) {
    setState(() {
      historyBox.deleteAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView.builder(
        itemCount: historyBox.length,
        itemBuilder: (context, index) {
          final data = HistoryModel.fromMap(Map<String, dynamic>.from(historyBox.getAt(index)));

          return Card(
            child: ListTile(
              leading: const Icon(Icons.fastfood, size: 40, color: Colors.orange),
              title: Text(data.namaMakanan, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryDetailScreen(history: data),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteHistory(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
