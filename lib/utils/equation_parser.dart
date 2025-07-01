class EquationParser {
  Map<String, int> parseFormula(String formula) {
    final Map<String, int> elementCounts = {};
    final RegExp elementRegExp = RegExp(r'([A-Z][a-z]*)(\d*)');
    final RegExp parenthesisRegExp = RegExp(r'\(([A-Za-z0-9_]*)\)(\d*)');

    String workingFormula = formula;

    // Handle parentheses first
    while (parenthesisRegExp.hasMatch(workingFormula)) {
      workingFormula = workingFormula.replaceAllMapped(parenthesisRegExp, (match) {
        String innerFormula = match.group(1)!;
        int multiplier = int.tryParse(match.group(2) ?? '1') ?? 1;
        Map<String, int> innerCounts = parseFormula(innerFormula);
        innerCounts.forEach((element, count) {
          elementCounts.update(element, (value) => value + count * multiplier, ifAbsent: () => count * multiplier);
        });
        return ''; // Remove the parenthesis part from the working formula
      });
    }

    // Handle remaining elements
    workingFormula.replaceAllMapped(elementRegExp, (match) {
      String element = match.group(1)!;
      int count = int.tryParse(match.group(2) ?? '1') ?? 1;
      elementCounts.update(element, (value) => value + count, ifAbsent: () => count);
      return '';
    });

    return elementCounts;
  }

  MapEntry<int, Map<String, int>> parseFormulaWithCoeff(String formula) {
    final RegExp coeffRegExp = RegExp(r'^(\d+)([A-Za-z(])');
    int coeff = 1;
    String cleanFormula = formula;
    final match = coeffRegExp.firstMatch(formula);
    if (match != null) {
      coeff = int.parse(match.group(1)!);
      cleanFormula = formula.substring(match.group(1)!.length);
    }
    return MapEntry(coeff, parseFormula(cleanFormula));
  }

  Map<String, List<MapEntry<int, Map<String, int>>>> parseEquation(String equation) {
    final parts = equation.split('=');
    if (parts.length != 2) {
      throw FormatException('Invalid equation format. Expected format: Reactants = Products');
    }

    final String reactantsString = parts[0].trim();
    final String productsString = parts[1].trim();

    final List<String> reactantFormulas = reactantsString.split('+').map((s) => s.trim()).toList();
    final List<String> productFormulas = productsString.split('+').map((s) => s.trim()).toList();

    final List<MapEntry<int, Map<String, int>>> parsedReactants = reactantFormulas.map((f) => parseFormulaWithCoeff(f)).toList();
    final List<MapEntry<int, Map<String, int>>> parsedProducts = productFormulas.map((f) => parseFormulaWithCoeff(f)).toList();

    return {
      'reactants': parsedReactants,
      'products': parsedProducts,
    };
  }
} 