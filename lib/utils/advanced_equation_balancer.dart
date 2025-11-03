import 'intelligent_reaction_predictor.dart';
import 'correct_equation_balancer.dart';
import 'matrix_balancer.dart';

/// Улучшенный балансировщик химических уравнений
/// Интегрирует предсказание продуктов и балансировку
class AdvancedEquationBalancer {
  /// Балансировка уравнения с автоматическим предсказанием
  static BalancedEquationResult balance(String input, {bool autoMode = true}) {
    try {
      input = _normalizeFormula(input.trim());
      
      final hasEqual = input.contains('=') || input.contains('→');
      
      // Режим АВТО: только реагенты
      if (autoMode && !hasEqual) {
        return _autoBalance(input);
      }
      
      // Режим РУЧНОЙ: полное уравнение
      if (hasEqual) {
        return _manualBalance(input);
      }
      
      // Если режим АВТО не сработал, пробуем предсказать
      return _autoBalance(input);
      
    } catch (e) {
      return BalancedEquationResult(
        balancedEquation: '',
        explanation: 'Ошибка: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  /// Автоматическая балансировка: только реагенты
  static BalancedEquationResult _autoBalance(String reactants) {
    final reactantList = reactants
        .split('+')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    if (reactantList.isEmpty) {
      return BalancedEquationResult(
        balancedEquation: '',
        explanation: 'Введите реагенты реакции',
        isSuccess: false,
      );
    }
    
    // Предсказываем продукты
    final prediction = IntelligentReactionPredictor.predictProducts(reactantList);
    
    if (!prediction.isPossible || prediction.products.isEmpty) {
      return BalancedEquationResult(
        balancedEquation: '',
        explanation: prediction.explanation,
        isSuccess: false,
      );
    }
    
    // Формируем полное уравнение
    final fullEquation = reactantList.join(' + ') + ' = ' + prediction.products.join(' + ');
    
    // Балансируем уравнение матричным баланcером (с объяснением)
    final mr = MatrixEquationBalancer.balance(fullEquation);
    final balanced = mr.balancedEquation.isNotEmpty ? mr.balancedEquation : CorrectEquationBalancer.balance(fullEquation);
    
    if (balanced.startsWith('Ошибка') || balanced.startsWith('Не удалось')) {
      return BalancedEquationResult(
        balancedEquation: '',
        explanation: balanced,
        isSuccess: false,
      );
    }
    
    // Формируем объяснение
    final explanation = _buildExplanation(
      reactantList,
      prediction.products,
      balanced,
      prediction,
    );
    
    return BalancedEquationResult(
      balancedEquation: balanced,
      explanation: explanation,
      isSuccess: true,
      reactionType: prediction.reactionType,
      reactants: reactantList,
      predictedProducts: prediction.products,
    );
  }

  /// Ручная балансировка: полное уравнение
  static BalancedEquationResult _manualBalance(String input) {
    final mr = MatrixEquationBalancer.balance(input);
    final balanced = mr.balancedEquation.isNotEmpty ? mr.balancedEquation : CorrectEquationBalancer.balance(input);
    
    if (balanced.startsWith('Ошибка') || balanced.startsWith('Не удалось')) {
      return BalancedEquationResult(
        balancedEquation: '',
        explanation: balanced,
        isSuccess: false,
      );
    }
    
    // Парсим уравнение
    final parts = input.replaceAll('→', '=').split('=');
    final left = parts[0].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final right = parts[1].split('+').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    final explanation = _buildManualExplanation(left, right, balanced);
    
    return BalancedEquationResult(
      balancedEquation: balanced,
      explanation: explanation,
      isSuccess: true,
      reactants: left,
      predictedProducts: right,
    );
  }

  /// Построение объяснения для автоматического режима
  static String _buildExplanation(
    List<String> reactants,
    List<String> predictedProducts,
    String balancedEquation,
    ReactionPrediction prediction,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 **Результат балансировки:**');
    buffer.writeln('$balancedEquation');
    buffer.writeln('');
    
    if (prediction.reactionType != null) {
      buffer.writeln('🔬 **Тип реакции:** ${prediction.reactionType}');
      buffer.writeln('');
    }
    
    buffer.writeln('📝 **Ход решения:**');
    buffer.writeln('1. **Реагенты:** ${reactants.join(' + ')}');
    buffer.writeln('2. **Предсказанные продукты:** ${predictedProducts.join(' + ')}');
    buffer.writeln('3. **Объяснение:** ${prediction.explanation}');
    buffer.writeln('4. **Сбалансированное уравнение:** $balancedEquation');
    buffer.writeln('');
    
    buffer.writeln('✅ Уравнение успешно сбалансировано методом матричного расчета.');
    
    return buffer.toString();
  }

  /// Построение объяснения для ручного режима
  static String _buildManualExplanation(
    List<String> left,
    List<String> right,
    String balancedEquation,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 **Результат балансировки:**');
    buffer.writeln('$balancedEquation');
    buffer.writeln('');
    
    buffer.writeln('📝 **Ход решения:**');
    buffer.writeln('1. **Исходное уравнение:** ${left.join(' + ')} = ${right.join(' + ')}');
    buffer.writeln('2. **Метод:** Матричный метод Гаусса');
    buffer.writeln('3. **Сбалансированное уравнение:** $balancedEquation');
    buffer.writeln('');
    
    buffer.writeln('✅ Уравнение успешно проверено и сбалансировано.');
    
    return buffer.toString();
  }

  /// Нормализация формулы
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
}

/// Результат балансировки уравнения
class BalancedEquationResult {
  final String balancedEquation;
  final String explanation;
  final bool isSuccess;
  final String? reactionType;
  final List<String>? reactants;
  final List<String>? predictedProducts;

  BalancedEquationResult({
    required this.balancedEquation,
    required this.explanation,
    required this.isSuccess,
    this.reactionType,
    this.reactants,
    this.predictedProducts,
  });
}







