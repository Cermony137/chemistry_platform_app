import 'package:flutter/material.dart';
import 'package:chemistry_platform_app/utils/equation_parser.dart';
import 'package:equations/equations.dart';
import 'dart:math';
import 'package:chemistry_platform_app/utils/reaction_predictor.dart';
import 'package:chemistry_platform_app/utils/equation_balancer.dart';

class AnalyticalModulePageSimple extends StatefulWidget {
  const AnalyticalModulePageSimple({super.key});

  @override
  State<AnalyticalModulePageSimple> createState() => _AnalyticalModulePageSimpleState();
}

class _AnalyticalModulePageSimpleState extends State<AnalyticalModulePageSimple> {
  final TextEditingController _equationController = TextEditingController();
  String _balancedEquation = '';
  final EquationParser _parser = EquationParser();
  final ReactionPredictor _predictor = ReactionPredictor();

  void _insertTemplate(String formula) {
    final text = _equationController.text;
    final selection = _equationController.selection;
    final newText = text.replaceRange(selection.start, selection.end, formula);
    _equationController.text = newText;
    _equationController.selection = TextSelection.collapsed(offset: selection.start + formula.length);
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
            const Text(
              'Быстрые кнопки:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _insertTemplate('H2'),
                  child: const Text('H2'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('O2'),
                  child: const Text('O2'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('H2O'),
                  child: const Text('H2O'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('NaOH'),
                  child: const Text('NaOH'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('HCl'),
                  child: const Text('HCl'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('NaCl'),
                  child: const Text('NaCl'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('CO2'),
                  child: const Text('CO2'),
                ),
                ElevatedButton(
                  onPressed: () => _insertTemplate('CaCO3'),
                  child: const Text('CaCO3'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
