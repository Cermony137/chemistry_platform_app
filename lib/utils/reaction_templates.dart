// База знаний: шаблоны реакций для автодополнения продуктов
// Ключ — реагенты (отсортированные формулы через +), значение — продукты
final Map<String, String> reactionTemplates = {
  // Реакции обмена
  'NaOH+HCl': 'NaCl+H2O',
  'AgNO3+NaCl': 'AgCl+NaNO3',
  'BaCl2+Na2SO4': 'BaSO4+2NaCl',
  // Замещение
  'Fe+CuSO4': 'FeSO4+Cu',
  'Zn+HCl': 'ZnCl2+H2',
  // Разложение
  'CaCO3': 'CaO+CO2',
  'KClO3': 'KCl+O2',
  // Органика (горение)
  'C2H6+O2': 'CO2+H2O',
  'C6H12O6+O2': 'CO2+H2O',
  // Кислотно-основные
  'H2SO4+NaOH': 'Na2SO4+H2O',
  'HNO3+KOH': 'KNO3+H2O',
  // Примеры с ионами
  'Fe{3+}+e{-}': 'Fe',
  'Cl2+e{-}': 'Cl{-}',
}; 