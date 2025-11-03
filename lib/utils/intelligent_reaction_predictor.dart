import 'compound_classifier.dart';

/// Интеллектуальный предсказатель продуктов химических реакций
/// Использует химические законы для предсказания продуктов
class IntelligentReactionPredictor {
  /// Предсказывает продукты реакции на основе химических законов
  static ReactionPrediction predictProducts(List<String> reactants) {
    final cleaned = reactants.map((r) => _cleanFormula(r)).toList();
    final classes = cleaned.map((r) => CompoundClassifier.classify(r)).toList();
    
    // 1. Реакция нейтрализации: кислота + основание = соль + вода
    final acidIndex = _findIndexByClass(classes, [
      CompoundClass.strongAcid,
      CompoundClass.weakAcid,
      CompoundClass.acid,
    ]);
    final baseIndex = _findIndexByClass(classes, [
      CompoundClass.strongBase,
      CompoundClass.weakBase,
      CompoundClass.base,
    ]);
    
    if (acidIndex != -1 && baseIndex != -1) {
      return _predictNeutralization(cleaned[acidIndex], cleaned[baseIndex]);
    }
    
    // 2. Металл + кислота = соль + водород
    final metalIndex = _findIndexByClass(classes, [CompoundClass.metal]);
    if (metalIndex != -1 && acidIndex != -1) {
      return _predictMetalAcidReaction(cleaned[metalIndex], cleaned[acidIndex]);
    }
    
    // 3. Горение: элемент/соединение + O2
    final o2Index = cleaned.indexWhere((r) => r == 'O2');
    if (o2Index != -1 && reactants.length > 1) {
      final other = cleaned.where((r) => r != 'O2').toList();
      if (other.length == 1) {
        return _predictCombustion(other[0]);
      }
    }
    
    // 4. Металл + неметалл = бинарное соединение
    if (metalIndex != -1) {
      final nonmetalIndex = _findIndexByClass(classes, [CompoundClass.nonmetal]);
      if (nonmetalIndex != -1) {
        return _predictBinaryCompound(cleaned[metalIndex], cleaned[nonmetalIndex]);
      }
    }
    
    // 5. Оксид металла + вода = основание
    final metalOxideIndex = _findIndexByClass(classes, [CompoundClass.metalOxide]);
    final waterIndex = cleaned.indexWhere((r) => r == 'H2O');
    if (metalOxideIndex != -1 && waterIndex != -1) {
      return _predictMetalOxideWater(cleaned[metalOxideIndex]);
    }
    
    // 6. Оксид неметалла + вода = кислота
    final nonmetalOxideIndex = _findIndexByClass(classes, [CompoundClass.nonmetalOxide]);
    if (nonmetalOxideIndex != -1 && waterIndex != -1) {
      return _predictNonmetalOxideWater(cleaned[nonmetalOxideIndex]);
    }
    
    // 7. Соль + кислота = новая соль + новая кислота (обменная реакция)
    final saltIndex = _findIndexByClass(classes, [
      CompoundClass.salt,
      CompoundClass.solubleSalt,
      CompoundClass.insolubleSalt,
    ]);
    if (saltIndex != -1 && acidIndex != -1) {
      return _predictSaltAcidReaction(cleaned[saltIndex], cleaned[acidIndex]);
    }
    
    // 8. Соль + соль = обмен с проверкой образования осадка
    final saltIndex2 = _findSecondSaltIndex(classes, saltIndex);
    if (saltIndex != -1 && saltIndex2 != -1) {
      return _predictSaltSaltExchange(cleaned[saltIndex], cleaned[saltIndex2]);
    }
    
    // 9. Металл + кислород = оксид
    if (metalIndex != -1 && o2Index != -1) {
      return _predictMetalOxygen(cleaned[metalIndex]);
    }
    
    return ReactionPrediction(
      products: [],
      explanation: 'Не удалось предсказать продукты реакции. Укажите полное уравнение.',
      isPossible: false,
    );
  }

  /// Реакция нейтрализации: кислота + основание = соль + вода
  static ReactionPrediction _predictNeutralization(String acid, String base) {
    // Получаем кислотный остаток
    final acidResidue = _getAcidResidue(acid);
    // Получаем катион основания
    final cation = _getCation(base);
    
    final salt = _formSalt(cation, acidResidue);
    final products = [salt, 'H2O'];
    
    return ReactionPrediction(
      products: products,
      explanation: 'Реакция нейтрализации: кислота $acid реагирует с основанием $base, образуя соль $salt и воду H2O',
      isPossible: true,
      reactionType: 'Нейтрализация',
    );
  }

  /// Металл + кислота = соль + водород
  static ReactionPrediction _predictMetalAcidReaction(String metal, String acid) {
    // Получаем кислотный остаток
    final acidResidue = _getAcidResidue(acid);
    // Определяем валентность металла
    final metalValency = _getMetalValency(metal);
    
    final salt = _formSaltWithValency(metal, metalValency, acidResidue);
    final products = [salt, 'H2'];
    
    // Проверка по ряду активности металлов
    final isActive = _isActiveMetal(metal);
    if (!isActive) {
      return ReactionPrediction(
        products: [],
        explanation: 'Металл $metal находится после водорода в ряду активности и не вытесняет водород из кислот',
        isPossible: false,
      );
    }
    
    return ReactionPrediction(
      products: products,
      explanation: 'Активный металл $metal вытесняет водород из кислоты $acid, образуя соль $salt и водород H2',
      isPossible: true,
      reactionType: 'Вытеснение водорода',
    );
  }

  /// Горение органических соединений и элементов
  static ReactionPrediction _predictCombustion(String compound) {
    if (compound == 'H2') {
      return ReactionPrediction(
        products: ['H2O'],
        explanation: 'Горение водорода: 2H2 + O2 = 2H2O',
        isPossible: true,
        reactionType: 'Горение',
      );
    }
    
    if (compound == 'C') {
      return ReactionPrediction(
        products: ['CO2'],
        explanation: 'Горение углерода: C + O2 = CO2',
        isPossible: true,
        reactionType: 'Горение',
      );
    }
    
    if (compound == 'S') {
      return ReactionPrediction(
        products: ['SO2'],
        explanation: 'Горение серы: S + O2 = SO2',
        isPossible: true,
        reactionType: 'Горение',
      );
    }
    
    if (compound == 'CH4') {
      return ReactionPrediction(
        products: ['CO2', 'H2O'],
        explanation: 'Горение метана: CH4 + 2O2 = CO2 + 2H2O',
        isPossible: true,
        reactionType: 'Горение углеводорода',
      );
    }
    
    // Общий случай горения углеводородов
    if (_isHydrocarbon(compound)) {
      return ReactionPrediction(
        products: ['CO2', 'H2O'],
        explanation: 'Горение углеводорода: $compound + O2 = CO2 + H2O',
        isPossible: true,
        reactionType: 'Горение углеводорода',
      );
    }
    
    return ReactionPrediction(
      products: [],
      explanation: 'Не удалось определить продукты горения для $compound',
      isPossible: false,
    );
  }

  /// Бинарное соединение: металл + неметалл
  static ReactionPrediction _predictBinaryCompound(String metal, String nonmetal) {
    if (nonmetal == 'H2') {
      // Некоторые металлы образуют гидриды
      return ReactionPrediction(
        products: [metal + 'H2'],
        explanation: 'Реакция образования гидрида',
        isPossible: true,
        reactionType: 'Образование бинарного соединения',
      );
    }
    
    if (nonmetal == 'Cl2' || nonmetal == 'F2' || nonmetal == 'Br2' || nonmetal == 'I2') {
      final halide = metal + nonmetal.substring(0, 1);
      return ReactionPrediction(
        products: [halide],
        explanation: 'Образование галогенида: $metal + $nonmetal = $halide',
        isPossible: true,
        reactionType: 'Образование бинарного соединения',
      );
    }
    
    if (nonmetal == 'O2') {
      return _predictMetalOxygen(metal);
    }
    
    return ReactionPrediction(
      products: [],
      explanation: 'Не удалось предсказать бинарное соединение',
      isPossible: false,
    );
  }

  /// Оксид металла + вода = основание
  static ReactionPrediction _predictMetalOxideWater(String oxide) {
    final metal = _extractMetal(oxide);
    if (metal == null) return ReactionPrediction(products: [], explanation: 'Ошибка', isPossible: false);
    
    final base = metal == 'Ca' || metal == 'Sr' || metal == 'Ba' 
        ? '$metal(OH)2'
        : '$metal(OH)';
    
    return ReactionPrediction(
      products: [base],
      explanation: 'Оксид $oxide реагирует с водой, образуя основание $base',
      isPossible: true,
      reactionType: 'Гидратация оксида',
    );
  }

  /// Оксид неметалла + вода = кислота
  static ReactionPrediction _predictNonmetalOxideWater(String oxide) {
    final nonmetal = _extractNonmetal(oxide);
    if (nonmetal == null) return ReactionPrediction(products: [], explanation: 'Ошибка', isPossible: false);
    
    String acid;
    switch (oxide) {
      case 'CO2':
        acid = 'H2CO3';
        break;
      case 'SO2':
        acid = 'H2SO3';
        break;
      case 'SO3':
        acid = 'H2SO4';
        break;
      case 'NO2':
        acid = 'HNO3';
        break;
      case 'P2O5':
        acid = 'H3PO4';
        break;
      default:
        acid = 'H' + nonmetal + 'O';
    }
    
    return ReactionPrediction(
      products: [acid],
      explanation: 'Оксид $oxide реагирует с водой, образуя кислоту $acid',
      isPossible: true,
      reactionType: 'Гидратация оксида',
    );
  }

  /// Соль + кислота = новая соль + новая кислота
  static ReactionPrediction _predictSaltAcidReaction(String salt, String acid) {
    // Простой случай: карбонаты с кислотами дают CO2
    if (salt.contains('CO3')) {
      final newSalt = _replaceAnion(salt, _getAcidResidue(acid));
      return ReactionPrediction(
        products: [newSalt, 'H2O', 'CO2'],
        explanation: 'Карбонат реагирует с кислотой, выделяя углекислый газ',
        isPossible: true,
        reactionType: 'Обменная реакция',
      );
    }
    
    // Общий случай обмена
    final cation = _getCation(salt);
    final anion = _getAnion(salt);
    final acidResidue = _getAcidResidue(acid);
    final acidCation = 'H';
    
    final newSalt = _formSalt(cation, acidResidue);
    final newAcid = _formSalt(acidCation, anion);
    
    return ReactionPrediction(
      products: [newSalt, newAcid],
      explanation: 'Обменная реакция: обмен ионами между солью и кислотой',
      isPossible: true,
      reactionType: 'Обменная реакция',
    );
  }

  /// Металл + кислород = оксид
  static ReactionPrediction _predictMetalOxygen(String metal) {
    final valency = _getMetalValency(metal);
    String oxide;
    
    switch (valency) {
      case 1:
        oxide = '${metal}2O';
        break;
      case 2:
        oxide = '${metal}O';
        break;
      case 3:
        oxide = '${metal}2O3';
        break;
      default:
        oxide = '${metal}O';
    }
    
    return ReactionPrediction(
      products: [oxide],
      explanation: 'Металл $metal окисляется кислородом, образуя оксид $oxide',
      isPossible: true,
      reactionType: 'Окисление',
    );
  }

  // Вспомогательные функции

  static String _cleanFormula(String formula) {
    int i = 0;
    while (i < formula.length && _isDigit(formula[i])) {
      i++;
    }
    return formula.substring(i);
  }

  static int _findIndexByClass(List<CompoundClass> classes, List<CompoundClass> targetClasses) {
    for (int i = 0; i < classes.length; i++) {
      if (targetClasses.contains(classes[i])) {
        return i;
      }
    }
    return -1;
  }

  static String _getAcidResidue(String acid) {
    if (acid == 'HCl') return 'Cl';
    if (acid == 'HBr') return 'Br';
    if (acid == 'HI') return 'I';
    if (acid == 'HNO3') return 'NO3';
    if (acid == 'H2SO4') return 'SO4';
    if (acid == 'H3PO4') return 'PO4';
    if (acid == 'H2CO3') return 'CO3';
    if (acid == 'H2S') return 'S';
    // Общий случай
    return acid.substring(1);
  }

  static String _getCation(String compound) {
    // Простые случаи
    if (compound.startsWith('Na')) return 'Na';
    if (compound.startsWith('K')) return 'K';
    if (compound.startsWith('Ca')) return 'Ca';
    if (compound.startsWith('Mg')) return 'Mg';
    if (compound.startsWith('Fe')) return 'Fe';
    if (compound.startsWith('Cu')) return 'Cu';
    if (compound.startsWith('Zn')) return 'Zn';
    if (compound.startsWith('Al')) return 'Al';
    
    // Извлекаем металл из начала формулы
    final match = RegExp(r'^([A-Z][a-z]?)').firstMatch(compound);
    return match?.group(1) ?? 'M';
  }

  static String _getAnion(String salt) {
    // Упрощенно: все после металла
    final cation = _getCation(salt);
    return salt.substring(cation.length);
  }

  static String _formSalt(String cation, String anion) {
    // Упрощенное формирование соли
    return '$cation$anion';
  }

  static String _formSaltWithValency(String metal, int valency, String anion) {
    // Определяем валентность аниона
    int anionValency = 1;
    if (anion == 'SO4') anionValency = 2;
    if (anion == 'PO4') anionValency = 3;
    if (anion == 'CO3') anionValency = 2;
    
    if (valency == anionValency) {
      return '$metal$anion';
    } else if (valency == 2 && anionValency == 1) {
      return '$metal${anion}2';
    } else if (valency == 1 && anionValency == 2) {
      return '${metal}2$anion';
    } else {
      return '$metal$anion';
    }
  }

  static int _getMetalValency(String metal) {
    // Типичные валентности металлов
    final Map<String, int> valencies = {
      'Na': 1, 'K': 1, 'Li': 1,
      'Ca': 2, 'Mg': 2, 'Ba': 2, 'Zn': 2, 'Fe': 2, 'Cu': 2,
      'Al': 3, 'Fe': 3,
    };
    return valencies[metal] ?? 2;
  }

  static bool _isActiveMetal(String metal) {
    // Металлы, стоящие до водорода в ряду активности
    final activeMetals = {
      'Li', 'K', 'Ca', 'Na', 'Mg', 'Al', 'Zn', 'Fe', 'Sn', 'Pb'
    };
    return activeMetals.contains(metal);
  }

  static int _findSecondSaltIndex(List<CompoundClass> classes, int firstSaltIndex){
    if (firstSaltIndex == -1) return -1;
    for (int i=0;i<classes.length;i++){
      if (i==firstSaltIndex) continue;
      if ({CompoundClass.salt, CompoundClass.solubleSalt, CompoundClass.insolubleSalt}.contains(classes[i])) return i;
    }
    return -1;
  }

  static ReactionPrediction _predictSaltSaltExchange(String salt1, String salt2){
    final c1 = _getCation(salt1); final a1 = _getAnion(salt1);
    final c2 = _getCation(salt2); final a2 = _getAnion(salt2);
    final p1 = _formSalt(c1, a2);
    final p2 = _formSalt(c2, a1);
    final insoluble = <String>[];
    if (_isInsoluble(p1)) insoluble.add(p1);
    if (_isInsoluble(p2)) insoluble.add(p2);
    final possible = insoluble.isNotEmpty;
    final expl = possible
      ? 'Обменная реакция солей: образуется осадок (${insoluble.join(', ')}).'
      : 'Обменная реакция солей возможна, осадок не образуется в упрощенной модели.';
    return ReactionPrediction(
      products: [p1, p2],
      explanation: expl,
      isPossible: true,
      reactionType: 'Обменная реакция',
    );
  }

  static bool _isInsoluble(String salt){
    // Мини-таблица нерастворимых солей для правил осадков
    const insol = {
      'AgCl', 'PbCl2', 'BaSO4', 'SrSO4', 'PbSO4', 'CaCO3', 'BaCO3', 'Ag2CO3', 'Fe(OH)3', 'Al(OH)3', 'Cu(OH)2'
    };
    return insol.contains(salt);
  }

  static bool _isHydrocarbon(String formula) {
    return RegExp(r'^C\d*H\d+$').hasMatch(formula);
  }

  static String? _extractMetal(String oxide) {
    final match = RegExp(r'^([A-Z][a-z]?)').firstMatch(oxide);
    return match?.group(1);
  }

  static String? _extractNonmetal(String oxide) {
    final match = RegExp(r'^([A-Z][a-z]?)').firstMatch(oxide);
    return match?.group(1);
  }

  static String _replaceAnion(String salt, String newAnion) {
    final cation = _getCation(salt);
    return '$cation$newAnion';
  }

  static bool _isDigit(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}

/// Результат предсказания реакции
class ReactionPrediction {
  final List<String> products;
  final String explanation;
  final bool isPossible;
  final String? reactionType;

  ReactionPrediction({
    required this.products,
    required this.explanation,
    required this.isPossible,
    this.reactionType,
  });
}

