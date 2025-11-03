class SimpleEquationBalancer {
  /// Простая и надежная балансировка уравнений
  static String balance(String input) {
    try {
      input = _normalizeFormula(input);
      
      // Если есть знак равенства, балансируем готовое уравнение
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

  /// Предсказание продуктов для простых реакций
  static String? _predictProducts(String reactants) {
    final reactantList = reactants.split('+').map((e) => e.trim()).toList();
    
    // H2 + O2 = H2O
    if (reactantList.contains('H2') && reactantList.contains('O2')) {
      return 'H2O';
    }
    
    // H2 + Cl2 = HCl
    if (reactantList.contains('H2') && reactantList.contains('Cl2')) {
      return 'HCl';
    }
    
    // N2 + H2 = NH3
    if (reactantList.contains('N2') && reactantList.contains('H2')) {
      return 'NH3';
    }
    
    // C + O2 = CO2
    if (reactantList.contains('C') && reactantList.contains('O2')) {
      return 'CO2';
    }
    
    // S + O2 = SO2
    if (reactantList.contains('S') && reactantList.contains('O2')) {
      return 'SO2';
    }
    
    // NaOH + HCl = NaCl + H2O
    if (reactantList.contains('NaOH') && reactantList.contains('HCl')) {
      return 'NaCl + H2O';
    }
    
    // CH4 + O2 = CO2 + H2O
    if (reactantList.contains('CH4') && reactantList.contains('O2')) {
      return 'CO2 + H2O';
    }
    
    // Fe + HCl = FeCl2 + H2
    if (reactantList.contains('Fe') && reactantList.contains('HCl')) {
      return 'FeCl2 + H2';
    }
    
    return null;
  }

  /// Балансировка существующего уравнения
  static String _balanceExistingEquation(String input) {
    final parts = input.replaceAll('→', '=').split('=');
    if (parts.length != 2) throw Exception('Уравнение должно содержать знак = или →');
    
    final left = parts[0].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final right = parts[1].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    if (left.isEmpty || right.isEmpty) throw Exception('Укажите реагенты и продукты.');
    
    // Простая балансировка для известных реакций
    final result = _balanceKnownReaction(left, right);
    if (result != null) return result;
    
    // Общая балансировка
    return _balanceGeneral(left, right);
  }

  /// Балансировка известных реакций
  static String? _balanceKnownReaction(List<String> left, List<String> right) {
    final leftStr = left.join('+');
    final rightStr = right.join('+');
    
    // H2 + O2 = H2O
    if (leftStr.contains('H2') && leftStr.contains('O2') && rightStr.contains('H2O')) {
      return '2H2 + O2 = 2H2O';
    }
    
    // H2 + Cl2 = HCl
    if (leftStr.contains('H2') && leftStr.contains('Cl2') && rightStr.contains('HCl')) {
      return 'H2 + Cl2 = 2HCl';
    }
    
    // N2 + H2 = NH3
    if (leftStr.contains('N2') && leftStr.contains('H2') && rightStr.contains('NH3')) {
      return 'N2 + 3H2 = 2NH3';
    }
    
    // C + O2 = CO2
    if (leftStr.contains('C') && leftStr.contains('O2') && rightStr.contains('CO2')) {
      return 'C + O2 = CO2';
    }
    
    // NaOH + HCl = NaCl + H2O
    if (leftStr.contains('NaOH') && leftStr.contains('HCl') && 
        rightStr.contains('NaCl') && rightStr.contains('H2O')) {
      return 'NaOH + HCl = NaCl + H2O';
    }
    
    // CH4 + O2 = CO2 + H2O
    if (leftStr.contains('CH4') && leftStr.contains('O2') && 
        rightStr.contains('CO2') && rightStr.contains('H2O')) {
      return 'CH4 + 2O2 = CO2 + 2H2O';
    }
    
    // Fe + HCl = FeCl2 + H2
    if (leftStr.contains('Fe') && leftStr.contains('HCl') && 
        rightStr.contains('FeCl2') && rightStr.contains('H2')) {
      return 'Fe + 2HCl = FeCl2 + H2';
    }
    
    return null;
  }

  /// Общая балансировка уравнений
  static String _balanceGeneral(List<String> left, List<String> right) {
    // Собираем все элементы
    final elements = <String>{};
    for (final formula in [...left, ...right]) {
      elements.addAll(_parseFormula(formula).keys);
    }
    
    // Строим матрицу коэффициентов
    final matrix = <List<double>>[];
    for (final element in elements) {
      final row = <double>[];
      for (int i = 0; i < left.length; i++) {
        final counts = _parseFormula(left[i]);
        row.add((counts[element] ?? 0).toDouble());
      }
      for (int i = 0; i < right.length; i++) {
        final counts = _parseFormula(right[i]);
        row.add(-(counts[element] ?? 0).toDouble());
      }
      matrix.add(row);
    }
    
    // Решаем систему уравнений
    final coeffs = _solveSystem(matrix);
    if (coeffs == null) return 'Не удалось сбалансировать уравнение.';
    
    return _formatResult(left, right, coeffs);
  }

  /// Решение системы уравнений
  static List<int>? _solveSystem(List<List<double>> matrix) {
    final n = matrix[0].length;
    final res = List<double>.filled(n, 1.0);
    
    // Последний коэффициент = 1
    res[n - 1] = 1.0;
    
    // Решаем снизу вверх
    for (int i = matrix.length - 1; i >= 0; i--) {
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

  /// Форматирование результата
  static String _formatResult(List<String> left, List<String> right, List<int> coeffs) {
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

  /// Нормализация формулы
  static String _normalizeFormula(String s) {
    const sub = {'₀':'0','₁':'1','₂':'2','₃':'3','₄':'4','₅':'5','₆':'6','₇':'7','₈':'8','₉':'9'};
    const sup = {'⁰':'0','¹':'1','²':'2','³':'3','⁴':'4','⁵':'5','⁶':'6','⁷':'7','⁸':'8','⁹':'9'};
    s = s.split('').map((c) => sub[c] ?? sup[c] ?? c).join();
    return s;
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










