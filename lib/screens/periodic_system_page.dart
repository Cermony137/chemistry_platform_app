import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services; // For loading assets
import 'dart:convert'; // For JSON decoding
import 'package:chemistry_platform_app/models/element.dart' as chem_elements;

class PeriodicSystemPage extends StatefulWidget {
  const PeriodicSystemPage({super.key});

  @override
  State<PeriodicSystemPage> createState() => _PeriodicSystemPageState();
}

class _PeriodicSystemPageState extends State<PeriodicSystemPage> {
  List<chem_elements.Element> _elements = []; // Placeholder for elements

  @override
  void initState() {
    super.initState();
    _fetchElements(); // Placeholder for fetching data
  }

  Future<void> _fetchElements() async {
    try {
      final String response = await services.rootBundle.loadString('assets/PeriodicTableJSON.json');
      final data = await json.decode(response);
      setState(() {
        _elements = (data['elements'] as List)
            .map((e) => chem_elements.Element.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      // TODO: Handle error, e.g., show an error message
      debugPrint('Error loading periodic table data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Периодическая система'),
      ),
      body: _elements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // Adjust as needed for periodic table layout
                childAspectRatio: 1.0,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: _elements.length,
              itemBuilder: (context, index) {
                final element = _elements[index];
                return Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (element.imageUrl != null && element.imageUrl!.isNotEmpty)
                          Expanded(
                            child: Image.network(
                              element.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 24),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Text(element.symbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(element.atomicNumber.toString(), style: const TextStyle(fontSize: 10)),
                        if (element.russianName != null)
                          Text(
                            element.russianName!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        Text(
                          '${element.atomicMass.toStringAsFixed(3)}',
                          style: const TextStyle(fontSize: 9),
                        ),
                        if (element.electronConfiguration != null && element.electronConfiguration!.isNotEmpty)
                          Text(
                            element.electronConfiguration!,
                            style: const TextStyle(fontSize: 8),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 