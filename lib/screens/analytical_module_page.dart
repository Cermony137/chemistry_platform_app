import 'package:flutter/material.dart';
import 'package:chemistry_platform_app/utils/equation_parser.dart'; // Import the parser
import 'package:equations/equations.dart'; // Import the equations package
import 'dart:math';
import 'package:chemistry_platform_app/utils/reaction_predictor.dart';

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

  void _balanceEquation() {
    final String equationText = _equationController.text.trim();
    if (equationText.isEmpty) {
      setState(() {
        _balancedEquation = 'Пожалуйста, введите химическое уравнение.';
      });
      return;
    }

    String equationToBalance = equationText;
    // Если нет знака '=', пробуем предсказать продукты
    if (!equationText.contains('=')) {
      final reactants = equationText.split('+').map((e) => e.trim()).toList();
      final predicted = _predictor.predictProducts(reactants);
      if (predicted != null) {
        equationToBalance = equationText + ' = ' + predicted;
      } else {
        setState(() {
          _balancedEquation = 'Не удалось предсказать продукты для этих реагентов. Пожалуйста, введите продукты вручную.';
        });
        return;
      }
    }

    try {
      final parsedEquation = _parser.parseEquation(equationToBalance);
      final List<MapEntry<int, Map<String, int>>> reactants = parsedEquation['reactants']!;
      final List<MapEntry<int, Map<String, int>>> products = parsedEquation['products']!;

      if (reactants.isEmpty || products.isEmpty) {
        setState(() {
          _balancedEquation = 'Уравнение должно содержать как реагенты, так и продукты.';
        });
        return;
      }

      final Set<String> uniqueElements = {};
      for (var entry in reactants) {
        uniqueElements.addAll(entry.value.keys);
      }
      for (var entry in products) {
        uniqueElements.addAll(entry.value.keys);
      }
      final List<String> elements = uniqueElements.toList()..sort();

      final List<String> allFormulas = [
        ...reactants.map((e) => equationToBalance.split('=')[0].split('+')[reactants.indexOf(e)].trim()),
        ...products.map((e) => equationToBalance.split('=')[1].split('+')[products.indexOf(e)].trim()),
      ];

      final int numVariables = allFormulas.length;
      final int numEquations = elements.length;

      if (numEquations >= numVariables) {
        setState(() {
          _balancedEquation = 'Не удается сбалансировать: слишком много элементов или слишком мало соединений.';
        });
        return;
      }

      // Учитываем уже введённые коэффициенты
      final List<int> initialCoeffs = [
        ...reactants.map((e) => e.key),
        ...products.map((e) => e.key),
      ];

      // Составляем матрицу для системы уравнений
      List<List<int>> matrixData = List.generate(
        numEquations,
        (_) => List.filled(numVariables, 0),
      );

      for (int i = 0; i < numEquations; i++) {
        for (int j = 0; j < numVariables; j++) {
          final Map<String, int> formulaCounts =
              j < reactants.length ? reactants[j].value : products[j - reactants.length].value;
          final int elementCount = formulaCounts[elements[i]] ?? 0;
          matrixData[i][j] = (j < reactants.length ? elementCount : -elementCount) * initialCoeffs[j];
        }
      }

      // Преобразуем к double для совместимости с equations
      List<List<double>> matrixDataDouble =
          matrixData.map((row) => row.map((e) => e.toDouble()).toList()).toList();

      // Фиксируем последний коэффициент = 1
      List<List<double>> reducedMatrix =
          matrixDataDouble.map((row) => row.sublist(0, numVariables - 1)).toList();
      List<double> constants =
          List.generate(numEquations, (i) => -matrixDataDouble[i][numVariables - 1]);

      // Решаем систему
      try {
        final RealMatrix luMatrix = RealMatrix.fromData(
          rows: numEquations,
          columns: numVariables - 1,
          data: reducedMatrix,
        );
        final LUSolver solver = LUSolver(
          matrix: luMatrix,
          knownValues: constants,
        );
        final List<double> solution = solver.solve();
        final List<double> rawCoefficients = [...solution, 1.0];

        // Умножаем на НОК знаменателей для целых коэффициентов
        List<int> denominators = rawCoefficients.map((e) {
          final str = e.toStringAsFixed(8);
          final parts = str.split('.');
          if (parts.length == 2) {
            return BigInt.from(pow(10, parts[1].length)).toInt();
          }
          return 1;
        }).toList();
        int lcm = denominators.fold(1, (a, b) => a * b ~/ _gcd(a, b));
        List<int> integerCoefficients = rawCoefficients.map((e) => (e * lcm).round()).toList();

        // Учитываем начальные коэффициенты
        for (int i = 0; i < integerCoefficients.length; i++) {
          integerCoefficients[i] *= initialCoeffs[i];
        }

        // Сокращаем на НОД
        final int commonDivisor = _gcdList(integerCoefficients);
        integerCoefficients = integerCoefficients.map((e) => e ~/ commonDivisor).toList();
        if (integerCoefficients.any((element) => element < 0)) {
          integerCoefficients = integerCoefficients.map((e) => e.abs()).toList();
        }

        // Формируем итоговое уравнение
        StringBuffer balancedEqBuffer = StringBuffer();
        int currentFormulaIndex = 0;
        for (int i = 0; i < reactants.length; i++) {
          if (integerCoefficients[currentFormulaIndex] > 0) {
            balancedEqBuffer.write('${integerCoefficients[currentFormulaIndex] == 1 ? '' : integerCoefficients[currentFormulaIndex]}${allFormulas[currentFormulaIndex]}');
          }
          if (i < reactants.length - 1) {
            balancedEqBuffer.write(' + ');
          }
          currentFormulaIndex++;
        }
        balancedEqBuffer.write(' = ');
        for (int i = 0; i < products.length; i++) {
          if (integerCoefficients[currentFormulaIndex] > 0) {
            balancedEqBuffer.write('${integerCoefficients[currentFormulaIndex] == 1 ? '' : integerCoefficients[currentFormulaIndex]}${allFormulas[currentFormulaIndex]}');
          }
          if (i < products.length - 1) {
            balancedEqBuffer.write(' + ');
          }
          currentFormulaIndex++;
        }
        setState(() {
          _balancedEquation = balancedEqBuffer.toString();
        });
      } catch (e) {
        setState(() {
          _balancedEquation = 'Ошибка при решении системы: $e';
        });
      }
    } on FormatException catch (e) {
      setState(() {
        _balancedEquation = 'Ошибка: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _balancedEquation = 'Произошла непредвиденная ошибка: $e';
      });
    }
  }

  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитический модуль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _equationController,
              decoration: const InputDecoration(
                labelText: 'Введите химическое уравнение (например, H2 + O2 = H2O)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _balanceEquation,
              child: const Text('Сбалансировать уравнение'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _balancedEquation,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 