/// Классификатор химических соединений
/// Определяет класс соединения для предсказания продуктов реакций
class CompoundClassifier {
  // Металлы
  static final Set<String> metals = {
    'Li', 'Na', 'K', 'Rb', 'Cs', 'Fr', // Щелочные металлы
    'Be', 'Mg', 'Ca', 'Sr', 'Ba', 'Ra', // Щелочноземельные
    'Al', 'Ga', 'In', 'Tl',
    'Zn', 'Cd', 'Hg',
    'Fe', 'Co', 'Ni', 'Cu', 'Ag', 'Au',
    'Mn', 'Cr', 'Ti', 'V', 'W', 'Mo',
    'Sn', 'Pb', 'Bi', 'Sb',
  };

  // Неметаллы
  static final Set<String> nonmetals = {
    'H', 'C', 'N', 'O', 'P', 'S', 'Se',
    'F', 'Cl', 'Br', 'I', 'At',
    'He', 'Ne', 'Ar', 'Kr', 'Xe', 'Rn',
  };

  // Сильные кислоты
  static final Map<String, int> strongAcids = {
    'HCl': 1, 'HBr': 1, 'HI': 1, 'HNO3': 1,
    'H2SO4': 2, 'HClO4': 1, 'HClO3': 1,
  };

  // Слабые кислоты
  static final Set<String> weakAcids = {
    'H2CO3', 'H2S', 'HCN', 'HF', 'CH3COOH', 'H3PO4',
  };

  // Сильные основания
  static final Set<String> strongBases = {
    'NaOH', 'KOH', 'LiOH', 'RbOH', 'CsOH',
    'Ca(OH)2', 'Sr(OH)2', 'Ba(OH)2',
  };

  // Слабые основания
  static final Set<String> weakBases = {
    'NH3', 'NH4OH', 'Fe(OH)2', 'Fe(OH)3', 'Cu(OH)2', 'Zn(OH)2',
  };

  // Растворимые соли
  static final Set<String> solubleSalts = {
    'NaCl', 'KCl', 'CaCl2', 'MgCl2', 'AlCl3',
    'NaNO3', 'KNO3', 'Ca(NO3)2',
    'Na2SO4', 'K2SO4', 'CaSO4',
    'Na2CO3', 'K2CO3',
  };

  // Нерастворимые соли (образуют осадки)
  static final Map<String, String> insolubleSalts = {
    'AgCl': 'AgCl (белый осадок)',
    'AgBr': 'AgBr (желтый осадок)',
    'AgI': 'AgI (желтый осадок)',
    'BaSO4': 'BaSO4 (белый осадок)',
    'CaCO3': 'CaCO3 (белый осадок)',
    'CaSO4': 'CaSO4 (белый осадок)',
    'Cu(OH)2': 'Cu(OH)2 (синий осадок)',
    'Fe(OH)2': 'Fe(OH)2 (зеленый осадок)',
    'Fe(OH)3': 'Fe(OH)3 (коричневый осадок)',
  };

  // Оксиды металлов (основные)
  static final Set<String> metalOxides = {
    'Na2O', 'K2O', 'CaO', 'MgO', 'BaO', 'FeO', 'Fe2O3', 'CuO', 'ZnO',
  };

  // Оксиды неметаллов (кислотные)
  static final Set<String> nonmetalOxides = {
    'CO2', 'SO2', 'SO3', 'NO2', 'N2O5', 'P2O5', 'Cl2O7',
  };

  // Амфотерные оксиды
  static final Set<String> amphotericOxides = {
    'Al2O3', 'ZnO', 'BeO', 'SnO', 'PbO',
  };

  /// Определяет класс соединения
  static CompoundClass classify(String formula) {
    final clean = _cleanFormula(formula);
    
    // Простые вещества (элементы)
    if (_isSimpleElement(clean)) {
      if (metals.contains(clean)) {
        return CompoundClass.metal;
      } else if (nonmetals.contains(clean)) {
        return CompoundClass.nonmetal;
      }
      return CompoundClass.element;
    }

    // Кислоты
    if (_isAcid(clean)) {
      if (strongAcids.containsKey(clean)) {
        return CompoundClass.strongAcid;
      } else if (weakAcids.contains(clean)) {
        return CompoundClass.weakAcid;
      }
      return CompoundClass.acid;
    }

    // Основания
    if (_isBase(clean)) {
      if (strongBases.contains(clean)) {
        return CompoundClass.strongBase;
      } else if (weakBases.contains(clean)) {
        return CompoundClass.weakBase;
      }
      return CompoundClass.base;
    }

    // Соли
    if (_isSalt(clean)) {
      if (insolubleSalts.containsKey(clean)) {
        return CompoundClass.insolubleSalt;
      } else if (solubleSalts.contains(clean)) {
        return CompoundClass.solubleSalt;
      }
      return CompoundClass.salt;
    }

    // Оксиды
    if (_isOxide(clean)) {
      if (metalOxides.contains(clean)) {
        return CompoundClass.metalOxide;
      } else if (nonmetalOxides.contains(clean)) {
        return CompoundClass.nonmetalOxide;
      } else if (amphotericOxides.contains(clean)) {
        return CompoundClass.amphotericOxide;
      }
      return CompoundClass.oxide;
    }

    // Органические соединения
    if (_isOrganic(clean)) {
      return CompoundClass.organic;
    }

    return CompoundClass.unknown;
  }

  /// Очистка формулы от коэффициентов
  static String _cleanFormula(String formula) {
    // Убираем цифры в начале
    int i = 0;
    while (i < formula.length && _isDigit(formula[i])) {
      i++;
    }
    return formula.substring(i);
  }

  /// Проверка на простой элемент
  static bool _isSimpleElement(String formula) {
    // Простой элемент: одна или две буквы, возможно с цифрой (H2, O2, Cl2)
    final match = RegExp(r'^[A-Z][a-z]?\d*$').firstMatch(formula);
    return match != null && match.group(0) == formula;
  }

  /// Проверка на кислоту
  static bool _isAcid(String formula) {
    // Кислоты начинаются с H (HCl, H2SO4, HNO3)
    return formula.startsWith('H') && !formula.startsWith('H2O');
  }

  /// Проверка на основание
  static bool _isBase(String formula) {
    // Основания содержат OH (NaOH, Ca(OH)2)
    return formula.contains('OH');
  }

  /// Проверка на соль
  static bool _isSalt(String formula) {
    // Соли обычно содержат металл и кислотный остаток
    // Проверяем на наличие металла и отсутствие H в начале
    if (formula.startsWith('H')) return false;
    
    // Простая проверка: не кислота, не основание, не оксид
    return !_isAcid(formula) && 
           !_isBase(formula) && 
           !_isOxide(formula) &&
           !_isOrganic(formula);
  }

  /// Проверка на оксид
  static bool _isOxide(String formula) {
    // Оксиды обычно заканчиваются на O или O2, O3
    return RegExp(r'O\d*$').hasMatch(formula);
  }

  /// Проверка на органическое соединение
  static bool _isOrganic(String formula) {
    // Органические соединения содержат C и H
    return formula.contains('C') && formula.contains('H') && 
           !formula.startsWith('H') && // Не кислота
           !formula.contains('OH'); // Не спирт (упрощенно)
  }

  static bool _isDigit(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}

/// Классы химических соединений
enum CompoundClass {
  metal,           // Металл (Fe, Cu, Zn)
  nonmetal,        // Неметалл (O2, Cl2, H2)
  element,         // Элемент (неопределенный)
  strongAcid,      // Сильная кислота (HCl, H2SO4)
  weakAcid,        // Слабая кислота (H2CO3, CH3COOH)
  acid,            // Кислота (общее)
  strongBase,      // Сильное основание (NaOH, KOH)
  weakBase,        // Слабое основание (NH3)
  base,            // Основание (общее)
  solubleSalt,     // Растворимая соль (NaCl, KNO3)
  insolubleSalt,   // Нерастворимая соль (AgCl, BaSO4)
  salt,            // Соль (общее)
  metalOxide,      // Оксид металла (CaO, Fe2O3)
  nonmetalOxide,   // Оксид неметалла (CO2, SO2)
  amphotericOxide, // Амфотерный оксид (Al2O3, ZnO)
  oxide,           // Оксид (общее)
  organic,         // Органическое соединение (CH4, C2H6)
  unknown,         // Неизвестное соединение
}

/// Информация о соединении
class CompoundInfo {
  final String formula;
  final CompoundClass compoundClass;
  final Map<String, dynamic> properties;

  CompoundInfo({
    required this.formula,
    required this.compoundClass,
    this.properties = const {},
  });

  String get classDescription {
    switch (compoundClass) {
      case CompoundClass.metal:
        return 'Металл';
      case CompoundClass.nonmetal:
        return 'Неметалл';
      case CompoundClass.strongAcid:
        return 'Сильная кислота';
      case CompoundClass.weakAcid:
        return 'Слабая кислота';
      case CompoundClass.acid:
        return 'Кислота';
      case CompoundClass.strongBase:
        return 'Сильное основание';
      case CompoundClass.weakBase:
        return 'Слабое основание';
      case CompoundClass.base:
        return 'Основание';
      case CompoundClass.solubleSalt:
        return 'Растворимая соль';
      case CompoundClass.insolubleSalt:
        return 'Нерастворимая соль (осадок)';
      case CompoundClass.salt:
        return 'Соль';
      case CompoundClass.metalOxide:
        return 'Оксид металла (основный)';
      case CompoundClass.nonmetalOxide:
        return 'Оксид неметалла (кислотный)';
      case CompoundClass.amphotericOxide:
        return 'Амфотерный оксид';
      case CompoundClass.oxide:
        return 'Оксид';
      case CompoundClass.organic:
        return 'Органическое соединение';
      case CompoundClass.element:
        return 'Химический элемент';
      case CompoundClass.unknown:
        return 'Неизвестное соединение';
    }
  }
}

