class BalanceResult {
  final String balancedEquation;
  final bool isSuccess;
  final String explanation;

  const BalanceResult({
    required this.balancedEquation,
    required this.isSuccess,
    required this.explanation,
  });
}

/// Matrix-based balancer with optional charge conservation row.
/// Produces integer coefficients and an explanation string.
class MatrixEquationBalancer {
  static BalanceResult balance(String input) {
    try {
      final normalized = _normalize(input);
      final sides = normalized.replaceAll('→', '=').split('=');
      if (sides.length != 2) {
        return const BalanceResult(
          balancedEquation: '',
          isSuccess: false,
          explanation: 'Уравнение должно содержать знак = или →',
        );
      }

      final left = _splitSide(sides[0]);
      final right = _splitSide(sides[1]);
      if (left.isEmpty || right.isEmpty) {
        return const BalanceResult(
          balancedEquation: '',
          isSuccess: false,
          explanation: 'Укажите реагенты и продукты.',
        );
      }

      final species = [...left, ...right].map(_stripLeadingCoeff).toList();
      final speciesLeftLen = left.length;

      final Set<String> elements = {};
      final List<int> charges = [];
      for (final s in species) {
        final parsed = _parseSpecies(s);
        elements.addAll(parsed.atoms.keys);
        charges.add(parsed.charge);
      }

      final elementList = elements.toList();
      final m = elementList.length + (charges.any((c) => c != 0) ? 1 : 0);
      final n = species.length;

      final List<List<double>> A = List.generate(m, (_) => List.filled(n, 0.0));
      // Mass balance rows
      for (int r = 0; r < elementList.length; r++) {
        final el = elementList[r];
        for (int j = 0; j < n; j++) {
          final counts = _parseSpecies(species[j]).atoms;
          final value = counts[el] ?? 0;
          A[r][j] = (j < speciesLeftLen) ? value.toDouble() : -value.toDouble();
        }
      }
      // Charge balance row (if needed)
      if (m > elementList.length) {
        final r = elementList.length;
        for (int j = 0; j < n; j++) {
          final q = charges[j];
          A[r][j] = (j < speciesLeftLen) ? q.toDouble() : -q.toDouble();
        }
      }

      final coeffs = _nullspaceInteger(A);
      if (coeffs == null) {
        return const BalanceResult(
          balancedEquation: '',
          isSuccess: false,
          explanation: 'Не удалось найти целочисленные коэффициенты.',
        );
      }

      // Валидация: масса и заряд
      final validMass = _verifyMass(species, speciesLeftLen, elementList, coeffs);
      final validCharge = _verifyCharge(charges, speciesLeftLen, coeffs);
      if (!validMass) {
        return const BalanceResult(
          balancedEquation: '',
          isSuccess: false,
          explanation: 'Проверка не пройдена: не сохраняется количество атомов элементов.',
        );
      }
      if (!validCharge && charges.any((c)=>c!=0)) {
        return const BalanceResult(
          balancedEquation: '',
          isSuccess: false,
          explanation: 'Проверка не пройдена: не сохраняется суммарный заряд.',
        );
      }

      final leftStr = List.generate(speciesLeftLen, (i) => _formatCoeff(coeffs[i]) + species[i]).where((s)=>s.isNotEmpty).join(' + ');
      final rightStr = List.generate(n - speciesLeftLen, (k) { final i = k + speciesLeftLen; return _formatCoeff(coeffs[i]) + species[i]; }).where((s)=>s.isNotEmpty).join(' + ');

      final explanation = _buildExplanation(elementList, m>elementList.length, species, speciesLeftLen, coeffs, charges);
      return BalanceResult(
        balancedEquation: '$leftStr = $rightStr',
        isSuccess: true,
        explanation: explanation,
      );
    } catch (e) {
      return BalanceResult(
        balancedEquation: '',
        isSuccess: false,
        explanation: 'Ошибка: ${e.toString()}',
      );
    }
  }

  static String _normalize(String s) {
    const sub = {'₀':'0','₁':'1','₂':'2','₃':'3','₄':'4','₅':'5','₆':'6','₇':'7','₈':'8','₉':'9'};
    const sup = {'⁰':'0','¹':'1','²':'2','³':'3','⁴':'4','⁵':'5','⁶':'6','⁷':'7','⁸':'8','⁹':'9'};
    return s.split('').map((c)=>sub[c]??sup[c]??c).join();
  }

  static List<String> _splitSide(String s) => s.split('+').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList();

  static String _stripLeadingCoeff(String f) {
    int i=0; while(i<f.length && _isDigit(f[i])) i++; return f.substring(i);
  }

  static _Species _parseSpecies(String formula) {
    // Parse trailing ionic charge like SO4^2-, Fe3+, NH4+
    int charge = 0;
    String core = formula.trim();
    final hat = core.indexOf('^');
    if (hat != -1) {
      final base = core.substring(0, hat);
      final cstr = core.substring(hat+1);
      final sign = cstr.contains('-') ? -1 : 1;
      final digits = RegExp(r'[0-9]+').firstMatch(cstr)?.group(0);
      final magnitude = digits==null?1:int.parse(digits);
      core = base;
      charge = sign*magnitude;
    } else if (RegExp(r'[+-]$').hasMatch(core)) {
      charge = core.endsWith('-')? -1: 1;
      core = core.substring(0, core.length-1);
    }
    final atoms = _parseAtoms(core);
    return _Species(atoms, charge);
  }

  static Map<String,int> _parseAtoms(String formula){
    final Map<String,int> counts={};
    final List<Map<String,int>> stack=[];
    final List<int> multStack=[];
    int i=0; int multiplier=1;
    while(i<formula.length){
      final ch=formula[i];
      if(ch=='(' || ch=='['){
        stack.add(Map.of(counts));
        multStack.add(multiplier);
        counts.clear(); multiplier=1; i++; continue;
      }
      if(ch==')' || ch==']'){
        i++; int mul=1; int start=i; while(i<formula.length && _isDigit(formula[i])) i++; if(i>start) mul=int.parse(formula.substring(start,i));
        final inner=Map<String,int>.from(counts.map((k,v)=>MapEntry(k,v*mul)));
        counts.clear(); if(stack.isNotEmpty){ counts.addAll(stack.removeLast()); }
        for(final e in inner.keys){ counts[e]=(counts[e]??0)+inner[e]!; }
        if(multStack.isNotEmpty){ multiplier = multStack.removeLast(); }
        continue;
      }
      if(_isUpper(ch)){
        int start=i; i++; while(i<formula.length && _isLower(formula[i])) i++;
        final el=formula.substring(start,i);
        int cnt=1; start=i; while(i<formula.length && _isDigit(formula[i])) i++; if(i>start) cnt=int.parse(formula.substring(start,i));
        counts[el]=(counts[el]??0)+cnt*multiplier; multiplier=1; continue;
      }
      if(_isDigit(ch)){
        int start=i; while(i<formula.length && _isDigit(formula[i])) i++; multiplier=int.parse(formula.substring(start,i)); continue;
      }
      i++;
    }
    return counts;
  }

  static List<int>? _nullspaceInteger(List<List<double>> A){
    final m=A.length; final n=A[0].length;
    // Augment with zero RHS and compute RREF
    final M=A.map((r)=>List<double>.from(r)).toList();
    int row=0; for(int col=0; col<n && row<m; col++){
      int pivot=row; while(pivot<m && M[pivot][col].abs()<1e-12) pivot++; if(pivot==m) continue;
      final tmp=M[row]; M[row]=M[pivot]; M[pivot]=tmp;
      final pv=M[row][col]; if(pv.abs()>1e-12){ for(int j=col;j<n;j++){ M[row][j]/=pv; }}
      for(int i=0;i<m;i++){ if(i==row) continue; final f=M[i][col]; if(f.abs()<1e-12) continue; for(int j=col;j<n;j++){ M[i][j]-=f*M[row][j]; }}
      row++;
    }
    // Identify a free variable and set to 1
    final leading=List<int>.filled(m,-1);
    int r=0; for(int c=0;c<n && r<m;c++){ if(M[r][c].abs()>1e-10){ leading[r]=c; r++; }}
    final isLeading=List<bool>.filled(n,false); for(final c in leading){ if(c>=0 && c<n) isLeading[c]=true; }
    int freeCol = -1; for(int c=0;c<n;c++){ if(!isLeading[c]){ freeCol=c; break; }}
    if(freeCol==-1) freeCol=n-1;
    final sol=List<double>.filled(n,0.0); sol[freeCol]=1.0;
    // Back-substitute: for each leading row r with column c, x_c = -sum_{j>c} a_{rj} x_j
    for(int i=m-1;i>=0;i--){ final c = (i>=0 && i<m)? leading[i]:-1; if(c==null || c<0) continue; double sum=0.0; for(int j=c+1;j<n;j++){ sum+=M[i][j]*sol[j]; } sol[c]=-sum; }
    // Scale to integers and make positive
    final ints=_toIntegers(sol);
    if(ints==null) return null;
    if(ints.any((x)=>x<=0)){ final allNeg=ints.every((x)=>x<=0); if(allNeg){ return ints.map((e)=>e.abs()).toList(); } }
    return ints;
  }

  static List<int>? _toIntegers(List<double> v){
    final den = v.map((x){ final scaled=(x*10000).round(); return 10000~/ _gcd(scaled.abs(),10000); }).toList();
    int lcm=den[0]; for(int i=1;i<den.length;i++){ lcm=(lcm*den[i])~/ _gcd(lcm,den[i]); }
    final ints=v.map((x)=> (x*lcm).round()).toList();
    int g=ints.map((e)=>e.abs()).reduce(_gcd); if(g==0) return null; return ints.map((e)=> e~/g).toList();
  }

  static int _gcd(int a,int b){ a=a.abs(); b=b.abs(); while(b!=0){ final t=b; b=a%b; a=t;} return a; }
  static bool _isUpper(String s){ if(s.isEmpty) return false; final c=s.codeUnitAt(0); return c>=65&&c<=90; }
  static bool _isLower(String s){ if(s.isEmpty) return false; final c=s.codeUnitAt(0); return c>=97&&c<=122; }
  static bool _isDigit(String s){ if(s.isEmpty) return false; final c=s.codeUnitAt(0); return c>=48&&c<=57; }

  static String _formatCoeff(int c)=> c>1? '$c' : '';

  static String _buildExplanation(List<String> elements, bool hasCharge, List<String> species, int leftLen, List<int> coeffs, List<int> charges){
    final lines=<String>[];
    lines.add('Метод: матричный (система линейных уравнений).');
    lines.add('Уравнения по элементам: ' + elements.join(', ') + '.');
    if(hasCharge){ lines.add('Доп. уравнение: сохранение суммарного заряда.'); }
    lines.add('Решение → целочисленные коэффициенты через НОК знаменателей.');
    // Краткая сводка коэффициентов
    final leftPairs = List.generate(leftLen, (i)=>'${coeffs[i]}·${species[i]}');
    final rightPairs = List.generate(species.length-leftLen, (k){ final i=k+leftLen; return '${coeffs[i]}·${species[i]}';});
    lines.add('Коэффициенты: ' + leftPairs.join(' + ') + ' = ' + rightPairs.join(' + '));
    if (hasCharge) {
      final leftCharge = List.generate(leftLen, (i)=>coeffs[i]* (charges[i])).reduce((a,b)=>a+b);
      final rightCharge = List.generate(species.length-leftLen, (k){ final i=k+leftLen; return coeffs[i]* (charges[i]);}).reduce((a,b)=>a+b);
      lines.add('Проверка заряда: слева $leftCharge, справа $rightCharge');
    }
    return lines.join('\n');
  }

  static bool _verifyMass(List<String> species, int leftLen, List<String> elements, List<int> coeffs){
    for(final el in elements){
      int left=0; int right=0;
      for(int i=0;i<species.length;i++){
        final counts=_parseAtoms(species[i]);
        final v = counts[el]??0;
        if(i<leftLen) left += v*coeffs[i]; else right += v*coeffs[i];
      }
      if(left!=right) return false;
    }
    return true;
  }

  static bool _verifyCharge(List<int> charges, int leftLen, List<int> coeffs){
    int left=0; int right=0;
    for(int i=0;i<charges.length;i++){
      if(i<leftLen) left += charges[i]*coeffs[i]; else right += charges[i]*coeffs[i];
    }
    return left==right;
  }
}

class _Species{
  final Map<String,int> atoms; final int charge; _Species(this.atoms,this.charge);
}


