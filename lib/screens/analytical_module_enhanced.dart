import 'package:flutter/material.dart';
import 'package:chemistry_platform_app/utils/equation_parser.dart';
import 'package:equations/equations.dart';
import 'dart:math';
import 'package:chemistry_platform_app/utils/reaction_predictor.dart';
import 'package:chemistry_platform_app/utils/equation_balancer.dart';
import 'package:chemistry_platform_app/utils/enhanced_equation_balancer.dart';

class AnalyticalModuleEnhanced extends StatefulWidget {
  const AnalyticalModuleEnhanced({super.key});

  @override
  State<AnalyticalModuleEnhanced> createState() => _AnalyticalModuleEnhancedState();
}

class _AnalyticalModuleEnhancedState extends State<AnalyticalModuleEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _equationController = TextEditingController();
  final TextEditingController _formulaController = TextEditingController();
  final TextEditingController _massController = TextEditingController();
  final TextEditingController _molesController = TextEditingController();
  
  String _balancedEquation = '';
  String _molarMassResult = '';
  String _conversionResult = '';
  
  // История вычислений
  final List<Map<String, String>> _calculationHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _equationController.dispose();
    _formulaController.dispose();
    _massController.dispose();
    _molesController.dispose();
    super.dispose();
  }

  // Балансировка уравнений с автоматическим предсказанием
  void _balanceEquation() {
    final input = _equationController.text.trim();
    setState(() {
      _balancedEquation = EnhancedEquationBalancer.balanceWithPrediction(input);
      if (_balancedEquation.isNotEmpty && !_balancedEquation.startsWith('Не удалось') && !_balancedEquation.startsWith('Ошибка')) {
        _addToHistory('Балансировка', input, _balancedEquation);
      }
    });
  }

  // Расчет молярной массы
  void _calculateMolarMass() {
    final formula = _formulaController.text.trim();
    if (formula.isEmpty) return;
    
    // Простой расчет для основных элементов
    final molarMass = _getMolarMass(formula);
    setState(() {
      _molarMassResult = 'Молярная масса $formula: ${molarMass.toStringAsFixed(2)} г/моль';
      _addToHistory('Молярная масса', formula, '${molarMass.toStringAsFixed(2)} г/моль');
    });
  }

  // Конвертация моль ↔ граммы
  void _convertMolesToMass() {
    final formula = _formulaController.text.trim();
    final moles = double.tryParse(_molesController.text) ?? 0;
    if (formula.isEmpty || moles == 0) return;
    
    final molarMass = _getMolarMass(formula);
    final mass = moles * molarMass;
    setState(() {
      _conversionResult = '$moles моль $formula = ${mass.toStringAsFixed(2)} г';
      _addToHistory('Конвертация', '$moles моль $formula', '${mass.toStringAsFixed(2)} г');
    });
  }

  void _convertMassToMoles() {
    final formula = _formulaController.text.trim();
    final mass = double.tryParse(_massController.text) ?? 0;
    if (formula.isEmpty || mass == 0) return;
    
    final molarMass = _getMolarMass(formula);
    final moles = mass / molarMass;
    setState(() {
      _conversionResult = '$mass г $formula = ${moles.toStringAsFixed(3)} моль';
      _addToHistory('Конвертация', '$mass г $formula', '${moles.toStringAsFixed(3)} моль');
    });
  }

  // Простая база молярных масс
  double _getMolarMass(String formula) {
    final Map<String, double> atomicMasses = {
      'H': 1.008, 'C': 12.011, 'N': 14.007, 'O': 15.999,
      'S': 32.065, 'Cl': 35.453, 'Na': 22.990, 'K': 39.098,
      'Ca': 40.078, 'Mg': 24.305, 'Al': 26.982, 'Fe': 55.845,
      'Cu': 63.546, 'Zn': 65.38, 'Ag': 107.868, 'Ba': 137.327
    };
    
    // Упрощенный парсинг для основных формул
    if (formula == 'H2O') return 18.015;
    if (formula == 'H2SO4') return 98.079;
    if (formula == 'NaOH') return 39.997;
    if (formula == 'HCl') return 36.461;
    if (formula == 'NaCl') return 58.443;
    if (formula == 'CO2') return 44.009;
    if (formula == 'CaCO3') return 100.087;
    
    // Для простых элементов
    if (atomicMasses.containsKey(formula)) {
      return atomicMasses[formula]!;
    }
    
    return 0.0; // Неизвестная формула
  }

  void _addToHistory(String type, String input, String result) {
    setState(() {
      _calculationHistory.insert(0, {
        'type': type,
        'input': input,
        'result': result,
        'time': DateTime.now().toString().substring(11, 19)
      });
      if (_calculationHistory.length > 10) {
        _calculationHistory.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитический модуль'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.balance), text: 'Балансировка'),
            Tab(icon: Icon(Icons.scale), text: 'Молярные массы'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'Конвертация'),
            Tab(icon: Icon(Icons.history), text: 'История'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEquationBalancer(),
          _buildMolarMassCalculator(),
          _buildUnitConverter(),
          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildEquationBalancer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Умная балансировка уравнений',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Введите реагенты или полное уравнение. Система автоматически предскажет продукты!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _equationController,
            decoration: const InputDecoration(
              labelText: 'Введите реагенты или уравнение',
              hintText: 'Например: H2 + O2 или H2 + O2 = H2O',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.science),
            ),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          // Примеры быстрого ввода
          const Text(
            'Примеры для тестирования:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildExampleChip('H2 + O2'),
              _buildExampleChip('NaOH + HCl'),
              _buildExampleChip('CH4 + O2'),
              _buildExampleChip('Fe + HCl'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _balanceEquation,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Умная балансировка'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          if (_balancedEquation.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _balancedEquation.startsWith('Не удалось') || _balancedEquation.startsWith('Ошибка')
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                border: Border.all(
                  color: _balancedEquation.startsWith('Не удалось') || _balancedEquation.startsWith('Ошибка')
                      ? Colors.red
                      : Colors.green,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _balancedEquation.startsWith('Не удалось') || _balancedEquation.startsWith('Ошибка')
                        ? 'Результат:'
                        : 'Сбалансированное уравнение:',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _balancedEquation,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String example) {
    return ActionChip(
      label: Text(example),
      onPressed: () {
        _equationController.text = example;
      },
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }

  Widget _buildMolarMassCalculator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _formulaController,
            decoration: const InputDecoration(
              labelText: 'Введите химическую формулу',
              hintText: 'Например: H2SO4, NaOH, CaCO3',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculateMolarMass,
            child: const Text('Рассчитать молярную массу'),
          ),
          const SizedBox(height: 16),
          if (_molarMassResult.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _molarMassResult,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitConverter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _formulaController,
            decoration: const InputDecoration(
              labelText: 'Химическая формула',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _molesController,
                  decoration: const InputDecoration(
                    labelText: 'Моли',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _massController,
                  decoration: const InputDecoration(
                    labelText: 'Граммы',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _convertMolesToMass,
                  child: const Text('Моли → Граммы'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _convertMassToMoles,
                  child: const Text('Граммы → Моли'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_conversionResult.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _conversionResult,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'История вычислений:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _calculationHistory.isEmpty
                ? const Center(
                    child: Text(
                      'История пуста\nВыполните несколько вычислений',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _calculationHistory.length,
                    itemBuilder: (context, index) {
                      final item = _calculationHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTypeColor(item['type']!),
                            child: Text(
                              item['type']![0],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(item['input']!),
                          subtitle: Text(item['result']!),
                          trailing: Text(
                            item['time']!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Балансировка':
        return Colors.green;
      case 'Молярная масса':
        return Colors.blue;
      case 'Конвертация':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
