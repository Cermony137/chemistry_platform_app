import 'package:flutter/material.dart';

class ReferenceMaterialsPage extends StatelessWidget {
  const ReferenceMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочные материалы'),
      ),
      body: const Center(
        child: Text(
          'Здесь будет раздел со справочными материалами.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
} 