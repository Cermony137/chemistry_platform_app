import 'package:flutter/material.dart';
import 'package:chemistry_platform_app/utils/equation_parser.dart'; // Import the parser
import 'package:equations/equations.dart'; // Import the equations package
import 'dart:math';
import 'package:chemistry_platform_app/utils/reaction_predictor.dart';
import 'package:chemistry_platform_app/utils/equation_balancer.dart';

class AnalyticalModulePage extends StatefulWidget {
  const AnalyticalModulePage({super.key});

  @override
  State<AnalyticalModulePage> createState() => _AnalyticalModulePageState();
}

class _AnalyticalModulePageState extends State<AnalyticalModulePage> {
  final TextEditingController _equationController = TextEditingController();
  String _balancedEquation = '';
  final EquationParser _parser = EquationParser(); // Instantiate the parser
  final ReactionPredictor _predictor = ReactionPredictor();

  // --- Шаблоны по разделам ---
  final Map<String, List<String>> templates = {
    'Простые элементы': ['H2', 'O2', 'N2', 'Cl2', 'Fe', 'Na', 'K', 'Mg', 'Al', 'Cu'],
    'Щелочи': ['NaOH', 'KOH', 'Ca(OH)2', 'Ba(OH)2'],
    'Кислоты': ['HCl', 'H2SO4', 'HNO3', 'H3PO4', 'H2CO3'],
    'Основания': ['NH3', 'Fe(OH)2', 'Fe(OH)3'],
    'Соли': ['NaCl', 'K2SO4', 'CaCO3', 'CuSO4', 'FeCl3'],
    'Органика': ['CH4', 'C2H6', 'C6H12O6', 'C2H5OH'],
    'Ионы': ['Fe{3+}', 'SO4{2-}', 'Cl{-}', 'H{+}', 'e{-}'],
  };

  // --- Символы для вставки ---
  final List<String> symbols = [
    '(', ')', '+', '=', '→', '[', ']', '{', '}', '^', '_',
    '²', '³', '⁴', '₁', '₂', '₃', '₄',
  ];

  // Function to find the greatest common divisor of a list of numbers
  int _gcdList(List<int> numbers) {
    if (numbers.isEmpty) {
      return 1;
    }
    int result = numbers[0].abs();
    for (int i = 1; i < numbers.length; i++) {
      result = _gcd(result, numbers[i].abs());
    }
    return result;
  }

  // Helper function for gcd
  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  void _insertTemplate(String formula) {
    final text = _equationController.text;
    final selection = _equationController.selection;
    final newText = text.replaceRange(selection.start, selection.end, formula);
    _equationController.text = newText;
    _equationController.selection = TextSelection.collapsed(offset: selection.start + formula.length);
  }

  void _insertSymbol(String symbol) {
    final text = _equationController.text;
    final selection = _equationController.selection;
    final newText = text.replaceRange(selection.start, selection.end, symbol);
    _equationController.text = newText;
    _equationController.selection = TextSelection.collapsed(offset: selection.start + symbol.length);
  }

  void _balanceEquation() {
    final input = _equationController.text.trim();
    setState(() {
      _balancedEquation = EquationBalancer.balance(input);
    });
  }

  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аналитический модуль — Калькулятор уравнений')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _equationController,
              decoration: const InputDecoration(
                labelText: 'Введите химическое уравнение',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Панель символов
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: symbols.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: OutlinedButton(
                    onPressed: () => _insertSymbol(s),
                    child: Text(s, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _balanceEquation,
                  child: const Text('Сбалансировать'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _balancedEquation,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Заголовок для шаблонов
            const Text(
              'Шаблоны формул:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: templates.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((formula) {
                          return ActionChip(
                            label: Text(formula, style: const TextStyle(fontSize: 16)),
                            onPressed: () => _insertTemplate(formula),
                          );
                        }).toList(),
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 