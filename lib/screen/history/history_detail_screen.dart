import 'package:flutter/material.dart';
import 'package:schedule_generator/model/history_model.dart';


class HistoryDetailScreen extends StatelessWidget {
  final HistoryModel history;

  const HistoryDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(history.namaMakanan)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bahan:", style: Theme.of(context).textTheme.titleLarge),
              ...history.bahan.map((item) => Text("• $item")),
              const SizedBox(height: 16),
              Text("Langkah:", style: Theme.of(context).textTheme.titleLarge),
              ...history.langkah.map((item) => Text("• $item")),
            ],
          ),
        ),
      ),
    );
  }
}
