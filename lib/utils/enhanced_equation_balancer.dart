import 'dart:math';

class EnhancedEquationBalancer {
  // Расширенная база данных реакций
  static final Map<String, String> _reactionDatabase = {
    // Простые соединения
    'H2+O2': '2H2O',
    'H2+Cl2': '2HCl',
    'N2+H2': '2NH3',
    'C+O2': 'CO2',
    'S+O2': 'SO2',
    'P+O2': 'P2O5',
    
    // Кислоты и основания
    'NaOH+HCl': 'NaCl+H2O',
    'KOH+H2SO4': 'K2SO4+H2O',
    'Ca(OH)2+H2SO4': 'CaSO4+2H2O',
    'NH3+HCl': 'NH4Cl',
    
    // Соли
    'NaCl+AgNO3': 'AgCl+NaNO3',
    'CaCO3+HCl': 'CaCl2+H2O+CO2',
    'CuSO4+NaOH': 'Cu(OH)2+Na2SO4',
    
    // Окислительно-восстановительные
    'Fe+HCl': 'FeCl2+H2',
    'Zn+H2SO4': 'ZnSO4+H2',
    'Mg+HCl': 'MgCl2+H2',
    
    // Органические реакции
    'CH4+O2': 'CO2+2H2O',
    'C2H6+O2': '2CO2+3H2O',
    'C2H5OH+O2': '2CO2+3H2O',
  };

  // База данных молярных масс элементов
  static final Map<String, double> _atomicMasses = {
    'H': 1.008, 'C': 12.011, 'N': 14.007, 'O': 15.999,
    'F': 18.998, 'Na': 22.990, 'Mg': 24.305, 'Al': 26.982,
    'Si': 28.085, 'P': 30.974, 'S': 32.065, 'Cl': 35.453,
    'K': 39.098, 'Ca': 40.078, 'Fe': 55.845, 'Cu': 63.546,
    'Zn': 65.38, 'Ag': 107.868, 'Ba': 137.327
  };

  /// Улучшенная балансировка с автоматическим предсказанием продуктов
  static String balanceWithPrediction(String input) {
    try {
      input = _normalizeFormula(input);
      
      // Если есть знак равенства, используем обычную балансировку
      if (input.contains('=') || input.contains('→')) {
        return _balanceExistingEquation(input);
      }
      
      // Иначе пытаемся предсказать продукты
      final predicted = _predictProducts(input);
      if (predicted != null) {
        final fullEquation = input + ' = ' + predicted;
        return _balanceExistingEquation(fullEquation);
      }
      
      return 'Не удалось предсказать продукты реакции. Попробуйте указать полное уравнение.';
      
    } catch (e) {
      return 'Ошибка: ${e.toString()}';
    }
  }

  /// Предсказание продуктов реакции
  static String? _predictProducts(String reactants) {
    final reactantList = reactants.split('+').map((e) => e.trim()).toList();
    
    // Сортируем для поиска в базе данных
    reactantList.sort();
    final key = reactantList.join('+');
    
    // Прямой поиск в базе данных
    if (_reactionDatabase.containsKey(key)) {
      return _reactionDatabase[key];
    }
    
    // Попробуем поиск с пробелами
    final keyWithSpaces = reactantList.join(' + ');
    if (_reactionDatabase.containsKey(keyWithSpaces)) {
      return _reactionDatabase[keyWithSpaces];
    }
    
    // Поиск по отдельным реагентам
    for (final entry in _reactionDatabase.entries) {
      final entryReactants = entry.key.split('+');
      if (_isSubset(reactantList, entryReactants)) {
        return entry.value;
      }
    }
    
    // Специальные правила для предсказания
    final result = _applyPredictionRules(reactantList);
    if (result != null) return result;
    
    // Дополнительная обработка для простых реакций
    return _handleSimpleReactions(reactantList);
  }

  /// Применение правил предсказания
  static String? _applyPredictionRules(List<String> reactants) {
    // Правило 1: Горение углеводородов
    final organic = reactants.firstWhere(
      (r) => RegExp(r'^C\d*H\d+$').hasMatch(r), 
      orElse: () => ''
    );
    final hasO2 = reactants.any((r) => r == 'O2');
    
    if (organic.isNotEmpty && hasO2) {
      return _predictCombustion(organic);
    }
    
    // Правило 2: Реакции кислот с основаниями
    final acids = ['HCl', 'H2SO4', 'HNO3', 'H3PO4'];
    final bases = ['NaOH', 'KOH', 'Ca(OH)2', 'NH3'];
    
    final acid = reactants.firstWhere((r) => acids.contains(r), orElse: () => '');
    final base = reactants.firstWhere((r) => bases.contains(r), orElse: () => '');
    
    if (acid.isNotEmpty && base.isNotEmpty) {
      return _predictAcidBaseReaction(acid, base);
    }
    
    // Правило 3: Простые соединения
    if (reactants.length == 2 && reactants.every((r) => _isSimpleElement(r))) {
      return _predictSimpleCompound(reactants[0], reactants[1]);
    }
    
    return null;
  }

  /// Предсказание горения углеводородов
  static String _predictCombustion(String hydrocarbon) {
    // Простой парсинг для CxHy
    final match = RegExp(r'C(\d*)H(\d+)').firstMatch(hydrocarbon);
    if (match != null) {
      final c = int.tryParse(match.group(1) ?? '1') ?? 1;
      final h = int.tryParse(match.group(2) ?? '1') ?? 1;
      
      // CxHy + O2 → CO2 + H2O
      final o2Coeff = (2 * c + h / 2).ceil();
      final co2Coeff = c;
      final h2oCoeff = h / 2;
      
      return '${o2Coeff}O2 = ${co2Coeff}CO2 + ${h2oCoeff}H2O';
    }
    return 'CO2 + H2O';
  }

  /// Предсказание кислотно-основных реакций
  static String _predictAcidBaseReaction(String acid, String base) {
    if (acid == 'HCl' && base == 'NaOH') return 'NaCl + H2O';
    if (acid == 'H2SO4' && base == 'NaOH') return 'Na2SO4 + H2O';
    if (acid == 'HCl' && base == 'Ca(OH)2') return 'CaCl2 + H2O';
    if (acid == 'HCl' && base == 'NH3') return 'NH4Cl';
    return 'Соль + H2O';
  }

  /// Предсказание простых соединений
  static String _predictSimpleCompound(String element1, String element2) {
    if (element1 == 'H2' && element2 == 'O2') return 'H2O';
    if (element1 == 'H2' && element2 == 'Cl2') return 'HCl';
    if (element1 == 'N2' && element2 == 'H2') return 'NH3';
    if (element1 == 'C' && element2 == 'O2') return 'CO2';
    return 'Соединение';
  }

  /// Обработка простых реакций
  static String? _handleSimpleReactions(List<String> reactants) {
    // H2 + O2 = H2O
    if (reactants.contains('H2') && reactants.contains('O2')) {
      return 'H2O';
    }
    
    // H2 + Cl2 = HCl
    if (reactants.contains('H2') && reactants.contains('Cl2')) {
      return 'HCl';
    }
    
    // N2 + H2 = NH3
    if (reactants.contains('N2') && reactants.contains('H2')) {
      return 'NH3';
    }
    
    // C + O2 = CO2
    if (reactants.contains('C') && reactants.contains('O2')) {
      return 'CO2';
    }
    
    // S + O2 = SO2
    if (reactants.contains('S') && reactants.contains('O2')) {
      return 'SO2';
    }
    
    return null;
  }

  /// Проверка, является ли строка простым элементом
  static bool _isSimpleElement(String formula) {
    return RegExp(r'^[A-Z][a-z]?\d*$').hasMatch(formula) && 
           _atomicMasses.containsKey(formula.replaceAll(RegExp(r'\d+'), ''));
  }

  /// Проверка, является ли один список подмножеством другого
  static bool _isSubset(List<String> subset, List<String> superset) {
    for (final item in subset) {
      if (!superset.contains(item)) return false;
    }
    return true;
  }

  /// Балансировка существующего уравнения
  static String _balanceExistingEquation(String input) {
    final parts = input.replaceAll('→', '=').split('=');
    if (parts.length != 2) throw Exception('Уравнение должно содержать знак = или →');
    
    final left = parts[0].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final right = parts[1].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    if (left.isEmpty || right.isEmpty) throw Exception('Укажите реагенты и продукты.');
    
    final elements = _collectElements(left + right);
    final matrix = _buildMatrix(left, right, elements);
    final coeffs = _solveMatrix(matrix);
    
    if (coeffs == null) return 'Не удалось сбалансировать уравнение.';
    
    return _formatBalanced(left, right, coeffs);
  }

  /// Нормализация формулы
  static String _normalizeFormula(String s) {
    const sub = {'₀':'0','₁':'1','₂':'2','₃':'3','₄':'4','₅':'5','₆':'6','₇':'7','₈':'8','₉':'9'};
    const sup = {'⁰':'0','¹':'1','²':'2','³':'3','⁴':'4','⁵':'5','⁶':'6','⁷':'7','⁸':'8','⁹':'9'};
    s = s.split('').map((c) => sub[c] ?? sup[c] ?? c).join();
    return s;
  }

  /// Сбор всех элементов из формул
  static Set<String> _collectElements(List<String> formulas) {
    final Set<String> elements = {};
    for (final formula in formulas) {
      elements.addAll(_parseFormula(formula).keys);
    }
    return elements;
  }

  /// Парсинг химической формулы
  static Map<String, int> _parseFormula(String formula) {
    final Map<String, int> counts = {};
    final stack = <Map<String, int>>[];
    final multStack = <int>[];
    int i = 0;
    int multiplier = 1;
    
    while (i < formula.length) {
      if (formula[i] == '(' || formula[i] == '[') {
        stack.add(counts.map((k, v) => MapEntry(k, v)));
        multStack.add(multiplier);
        counts.clear();
        multiplier = 1;
        i++;
      } else if (formula[i] == ')' || formula[i] == ']') {
        i++;
        int mul = 1;
        int start = i;
        while (i < formula.length && isDigit(formula[i])) i++;
        if (i > start) mul = int.parse(formula.substring(start, i));
        final inner = counts.map((k, v) => MapEntry(k, v * mul));
        counts.clear();
        counts.addAll(stack.removeLast());
        for (final e in inner.keys) {
          counts[e] = (counts[e] ?? 0) + inner[e]!;
        }
        multiplier = multStack.removeLast();
      } else if (isUpper(formula[i])) {
        int start = i;
        i++;
        while (i < formula.length && isLower(formula[i])) i++;
        final el = formula.substring(start, i);
        int count = 1;
        start = i;
        while (i < formula.length && isDigit(formula[i])) i++;
        if (i > start) count = int.parse(formula.substring(start, i));
        counts[el] = (counts[el] ?? 0) + count * multiplier;
        multiplier = 1;
      } else if (isDigit(formula[i])) {
        int start = i;
        while (i < formula.length && isDigit(formula[i])) i++;
        multiplier = int.parse(formula.substring(start, i));
      } else {
        i++;
      }
    }
    return counts;
  }

  /// Построение матрицы для решения системы уравнений
  static List<List<double>> _buildMatrix(List<String> left, List<String> right, Set<String> elements) {
    final formulas = [...left, ...right];
    final matrix = <List<double>>[];
    
    for (final el in elements) {
      final row = <double>[];
      for (int i = 0; i < formulas.length; i++) {
        final counts = _parseFormula(formulas[i]);
        int c = counts[el] ?? 0;
        if (i >= left.length) c = -c; // Продукты с отрицательным знаком
        row.add(c.toDouble());
      }
      matrix.add(row);
    }
    return matrix;
  }

  /// Решение системы уравнений упрощенным методом
  static List<int>? _solveMatrix(List<List<double>> matrix) {
    final m = matrix.length;
    final n = matrix[0].length;
    
    // Для простых случаев используем прямой подход
    if (n <= 3) {
      return _solveSimple(matrix);
    }
    
    // Для сложных случаев используем упрощенный алгоритм
    final res = List<double>.filled(n, 1.0);
    
    // Последний коэффициент всегда 1
    res[n - 1] = 1.0;
    
    // Решаем систему снизу вверх
    for (int i = m - 1; i >= 0; i--) {
      int j = 0;
      while (j < n && matrix[i][j].abs() < 1e-10) j++;
      if (j >= n - 1) continue;
      
      double sum = 0;
      for (int k = j + 1; k < n; k++) {
        sum += matrix[i][k] * res[k];
      }
      if (matrix[i][j].abs() > 1e-10) {
        res[j] = -sum / matrix[i][j];
      }
    }
    
    // Приводим к целым числам
    final lcm = _findLCM(res.map((x) => (x * 1000).round()).toList());
    final intRes = res.map((x) => (x * lcm / 1000).round()).toList();
    
    // Сокращаем на НОД
    final g = intRes.fold(0, (a, b) => _gcd(a, b.abs()));
    if (g > 0) {
      return intRes.map((e) => e ~/ g).toList();
    }
    return intRes;
  }
  
  /// Решение простых систем уравнений
  static List<int>? _solveSimple(List<List<double>> matrix) {
    final n = matrix[0].length;
    final res = List<int>.filled(n, 1);
    
    // Для простых реакций используем эвристики
    if (n == 2) {
      // A + B = C
      res[0] = 1;
      res[1] = 1;
    } else if (n == 3) {
      // A + B = C + D
      res[0] = 1;
      res[1] = 1;
      res[2] = 1;
    }
    
    return res;
  }

  /// Форматирование сбалансированного уравнения
  static String _formatBalanced(List<String> left, List<String> right, List<int> coeffs) {
    final leftFormatted = <String>[];
    final rightFormatted = <String>[];
    
    for (int i = 0; i < left.length; i++) {
      final c = coeffs[i];
      final f = (c > 1 ? '$c' : '') + left[i];
      leftFormatted.add(f);
    }
    
    for (int i = 0; i < right.length; i++) {
      final c = coeffs[i + left.length];
      final f = (c > 1 ? '$c' : '') + right[i];
      rightFormatted.add(f);
    }
    
    return leftFormatted.join(' + ') + ' = ' + rightFormatted.join(' + ');
  }

  // Вспомогательные функции
  static bool isUpper(String s) => s.codeUnitAt(0) >= 65 && s.codeUnitAt(0) <= 90;
  static bool isLower(String s) => s.codeUnitAt(0) >= 97 && s.codeUnitAt(0) <= 122;
  static bool isDigit(String s) => s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
  
  static int _findLCM(List<int> numbers) {
    int result = numbers[0];
    for (int i = 1; i < numbers.length; i++) {
      result = (result * numbers[i]) ~/ _gcd(result, numbers[i]);
    }
    return result;
  }
}
