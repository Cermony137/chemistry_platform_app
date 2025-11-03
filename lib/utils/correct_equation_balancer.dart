/// Правильный балансировщик химических уравнений
/// Использует корректный алгоритм Гаусса для решения системы уравнений
class CorrectEquationBalancer {
  /// Балансировка уравнения с автоматическим предсказанием продуктов
  static String balance(String input) {
    try {
      input = _normalizeFormula(input.trim());
      
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
    final reactantList = reactants.split('+').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
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
    if (reactantList.contains('C') && reactantList.contains('O2') && !reactantList.contains('CO2')) {
      return 'CO2';
    }
    
    // S + O2 = SO2
    if (reactantList.contains('S') && reactantList.contains('O2') && !reactantList.contains('SO2')) {
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
    if (parts.length != 2) {
      throw Exception('Уравнение должно содержать знак = или →');
    }
    
    final left = parts[0].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final right = parts[1].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    if (left.isEmpty || right.isEmpty) {
      throw Exception('Укажите реагенты и продукты.');
    }
    
    // Убираем коэффициенты из формул перед парсингом
    final leftCleaned = left.map((f) => _removeCoefficient(f)).toList();
    final rightCleaned = right.map((f) => _removeCoefficient(f)).toList();
    
    // Собираем все элементы
    final elements = <String>{};
    for (final formula in [...leftCleaned, ...rightCleaned]) {
      elements.addAll(_parseFormula(formula).keys);
    }
    
    // Строим матрицу коэффициентов
    final matrix = _buildMatrix(leftCleaned, rightCleaned, elements);
    
    // Решаем систему уравнений методом Гаусса
    final coeffs = _solveGauss(matrix);
    if (coeffs == null || coeffs.isEmpty) {
      return 'Не удалось сбалансировать уравнение.';
    }
    
    // Проверяем корректность решения
    if (!_verifyBalance(leftCleaned, rightCleaned, coeffs, elements)) {
      return 'Не удалось найти целые коэффициенты.';
    }
    
    return _formatResult(leftCleaned, rightCleaned, coeffs);
  }

  /// Удаление коэффициента из начала формулы
  static String _removeCoefficient(String formula) {
    // Убираем цифры в начале строки
    int i = 0;
    while (i < formula.length && _isDigit(formula[i])) {
      i++;
    }
    return formula.substring(i);
  }

  /// Построение матрицы системы уравнений
  static List<List<double>> _buildMatrix(
    List<String> left, 
    List<String> right, 
    Set<String> elements
  ) {
    final formulas = [...left, ...right];
    final matrix = <List<double>>[];
    
    for (final element in elements) {
      final row = <double>[];
      for (int i = 0; i < formulas.length; i++) {
        final counts = _parseFormula(formulas[i]);
        int count = counts[element] ?? 0;
        // Для продуктов используем отрицательный знак
        if (i >= left.length) {
          count = -count;
        }
        row.add(count.toDouble());
      }
      matrix.add(row);
    }
    
    return matrix;
  }

  /// Решение системы уравнений методом Гаусса с приведением к целым числам
  static List<int>? _solveGauss(List<List<double>> matrix) {
    if (matrix.isEmpty || matrix[0].isEmpty) return null;
    
    final m = matrix.length; // Количество уравнений (элементов)
    final n = matrix[0].length; // Количество неизвестных (веществ)
    
    // Если уравнений меньше, чем неизвестных, добавляем ограничение
    // Последний коэффициент можно взять за 1
    if (m < n - 1) {
      return _solveWithConstraint(matrix);
    }
    
    // Приводим матрицу к ступенчатому виду методом Гаусса
    final augmented = matrix.map((row) => List<double>.from(row)).toList();
    
    int rank = 0;
    for (int col = 0; col < n - 1 && rank < m; col++) {
      // Ищем опорный элемент (первый ненулевой)
      int pivotRow = rank;
      while (pivotRow < m && augmented[pivotRow][col].abs() < 1e-10) {
        pivotRow++;
      }
      
      if (pivotRow == m) continue; // Все нули в этом столбце
      
      // Меняем строки местами
      if (pivotRow != rank) {
        final temp = augmented[rank];
        augmented[rank] = augmented[pivotRow];
        augmented[pivotRow] = temp;
      }
      
      // Нормализуем опорную строку
      final pivot = augmented[rank][col];
      if (pivot.abs() < 1e-10) continue;
      
      // Обнуляем элементы под опорным
      for (int i = rank + 1; i < m; i++) {
        if (augmented[i][col].abs() < 1e-10) continue;
        final factor = augmented[i][col] / pivot;
        for (int j = col; j < n; j++) {
          augmented[i][j] -= augmented[rank][j] * factor;
        }
      }
      
      rank++;
    }
    
    // Обратный ход: решаем систему
    final solution = List<double>.filled(n, 1.0);
    solution[n - 1] = 1.0; // Свободная переменная
    
    // Решаем снизу вверх
    for (int i = rank - 1; i >= 0; i--) {
      // Находим первый ненулевой элемент в строке
      int col = 0;
      while (col < n - 1 && augmented[i][col].abs() < 1e-10) {
        col++;
      }
      
      if (col >= n - 1) continue;
      
      // Вычисляем значение неизвестной
      double sum = 0.0;
      for (int j = col + 1; j < n; j++) {
        sum += augmented[i][j] * solution[j];
      }
      
      if (augmented[i][col].abs() > 1e-10) {
        solution[col] = -sum / augmented[i][col];
      }
    }
    
    // Приводим к целым числам через НОК знаменателей
    return _rationalize(solution);
  }

  /// Решение системы с ограничением (когда уравнений меньше, чем неизвестных)
  static List<int>? _solveWithConstraint(List<List<double>> matrix) {
    final n = matrix[0].length;
    final solution = List<double>.filled(n, 1.0);
    
    // Решаем систему, предполагая, что последний коэффициент = 1
    solution[n - 1] = 1.0;
    
    for (int i = matrix.length - 1; i >= 0; i--) {
      int j = 0;
      while (j < n && matrix[i][j].abs() < 1e-10) j++;
      if (j >= n - 1) continue;
      
      double sum = 0.0;
      for (int k = j + 1; k < n; k++) {
        sum += matrix[i][k] * solution[k];
      }
      if (matrix[i][j].abs() > 1e-10) {
        solution[j] = -sum / matrix[i][j];
      }
    }
    
    return _rationalize(solution);
  }

  /// Приведение дробных коэффициентов к целым числам
  static List<int>? _rationalize(List<double> solution) {
    if (solution.isEmpty) return null;
    
    // Находим наименьшее общее кратное знаменателей
    final denominators = solution.map((x) {
      if (x.abs() < 1e-10) return 1;
      // Преобразуем в дробь через умножение на большую степень 10
      final scaled = (x * 10000).round();
      final gcd = _gcd(scaled.abs(), 10000);
      return 10000 ~/ gcd;
    }).toList();
    
    int lcm = denominators[0];
    for (int i = 1; i < denominators.length; i++) {
      lcm = (lcm * denominators[i]) ~/ _gcd(lcm, denominators[i]);
    }
    
    // Умножаем все коэффициенты на НОК
    final intSolution = solution.map((x) => (x * lcm).round()).toList();
    
    // Находим НОД всех коэффициентов
    int gcd = intSolution[0].abs();
    for (int i = 1; i < intSolution.length; i++) {
      gcd = _gcd(gcd, intSolution[i].abs());
    }
    
    if (gcd == 0) return null;
    
    // Сокращаем на НОД
    final result = intSolution.map((x) => x ~/ gcd).toList();
    
    // Проверяем, что все коэффициенты положительные
    if (result.any((x) => x <= 0)) {
      // Умножаем на -1, если нужно
      if (result.any((x) => x < 0)) {
        return result.map((x) => x.abs()).toList();
      }
      return null;
    }
    
    return result;
  }

  /// Проверка корректности балансировки
  static bool _verifyBalance(
    List<String> left,
    List<String> right,
    List<int> coeffs,
    Set<String> elements
  ) {
    for (final element in elements) {
      int leftSum = 0;
      int rightSum = 0;
      
      for (int i = 0; i < left.length; i++) {
        final counts = _parseFormula(left[i]);
        leftSum += (counts[element] ?? 0) * coeffs[i];
      }
      
      for (int i = 0; i < right.length; i++) {
        final counts = _parseFormula(right[i]);
        rightSum += (counts[element] ?? 0) * coeffs[i + left.length];
      }
      
      if (leftSum != rightSum) {
        return false;
      }
    }
    
    return true;
  }

  /// Форматирование результата
  static String _formatResult(List<String> left, List<String> right, List<int> coeffs) {
    final leftFormatted = <String>[];
    final rightFormatted = <String>[];
    
    for (int i = 0; i < left.length; i++) {
      final c = coeffs[i];
      if (c <= 0) continue; // Пропускаем нулевые коэффициенты
      final f = (c > 1 ? '$c' : '') + left[i];
      leftFormatted.add(f);
    }
    
    for (int i = 0; i < right.length; i++) {
      final c = coeffs[i + left.length];
      if (c <= 0) continue;
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
        stack.add(Map<String, int>.from(counts));
        multStack.add(multiplier);
        counts.clear();
        multiplier = 1;
        i++;
      } else if (formula[i] == ')' || formula[i] == ']') {
        i++;
        int mul = 1;
        int start = i;
        while (i < formula.length && _isDigit(formula[i])) {
          i++;
        }
        if (i > start) {
          mul = int.parse(formula.substring(start, i));
        }
        final inner = Map<String, int>.from(counts.map((k, v) => MapEntry(k, v * mul)));
        counts.clear();
        if (stack.isNotEmpty) {
          counts.addAll(stack.removeLast());
        }
        for (final e in inner.keys) {
          counts[e] = (counts[e] ?? 0) + inner[e]!;
        }
        if (multStack.isNotEmpty) {
          multiplier = multStack.removeLast();
        }
      } else if (_isUpper(formula[i])) {
        int start = i;
        i++;
        while (i < formula.length && _isLower(formula[i])) {
          i++;
        }
        final el = formula.substring(start, i);
        int count = 1;
        start = i;
        while (i < formula.length && _isDigit(formula[i])) {
          i++;
        }
        if (i > start) {
          count = int.parse(formula.substring(start, i));
        }
        counts[el] = (counts[el] ?? 0) + count * multiplier;
        multiplier = 1;
      } else if (_isDigit(formula[i])) {
        int start = i;
        while (i < formula.length && _isDigit(formula[i])) {
          i++;
        }
        multiplier = int.parse(formula.substring(start, i));
      } else {
        i++;
      }
    }
    
    return counts;
  }

  /// Нормализация формулы (замена подстрочных/надстрочных символов)
  static String _normalizeFormula(String s) {
    const sub = {
      '₀': '0', '₁': '1', '₂': '2', '₃': '3', '₄': '4',
      '₅': '5', '₆': '6', '₇': '7', '₈': '8', '₉': '9'
    };
    const sup = {
      '⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4',
      '⁵': '5', '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9'
    };
    return s.split('').map((c) => sub[c] ?? sup[c] ?? c).join();
  }

  // Вспомогательные функции
  static bool _isUpper(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return code >= 65 && code <= 90;
  }

  static bool _isLower(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return code >= 97 && code <= 122;
  }

  static bool _isDigit(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}










