import 'package:flutter/material.dart';

typedef InsertCallback = void Function(String text);

class ChemKeyboard extends StatelessWidget {
  final InsertCallback onInsert;
  final EdgeInsetsGeometry padding;

  const ChemKeyboard({super.key, required this.onInsert, this.padding = const EdgeInsets.all(8)});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TabBar(
              labelColor: Colors.black87,
              tabs: [
                Tab(text: 'Элементы'),
                Tab(text: 'Соединения'),
                Tab(text: 'Цифры'),
                Tab(text: 'Символы'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: TabBarView(
                children: [
                  _buildGrid(_elements(), onInsert),
                  _buildGrid(_compounds(), onInsert),
                  _buildGrid(_digits(), onInsert),
                  _buildGrid(_symbols(), onInsert),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGrid(List<String> items, InsertCallback onInsert) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final text = items[index];
        return ElevatedButton(
          onPressed: () => onInsert(text),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(text),
        );
      },
    );
  }

  static List<String> _elements() {
    return [
      // Группа 1: основные неметаллы
      'H','O','C','N','P','S','Cl','F',
      // Группа 2: щелочные металлы
      'Li','Na','K','Rb','Cs',
      // Группа 3: щелочноземельные
      'Be','Mg','Ca','Sr','Ba',
      // Группа 4: переходные металлы (выборочно)
      'Fe','Cu','Zn','Ag','Au'
    ];
  }

  static List<String> _compounds() {
    return [
      // Кислоты
      'HCl','H2SO4','HNO3','H3PO4',
      // Основания
      'NaOH','KOH','Ca(OH)2','NH3',
      // Соли
      'NaCl','CaCO3','FeCl3','KMnO4',
      // Газы
      'O2','H2','N2','Cl2','CO2'
    ];
  }

  static List<String> _digits() {
    return ['1','2','3','4','5','6','7','8','9','0','₁','₂','₃','₄','₅','₆','₇','₈','₉','₀'];
  }

  static List<String> _symbols() {
    return ['(',')','[',']','+','→','•'];
  }
}


