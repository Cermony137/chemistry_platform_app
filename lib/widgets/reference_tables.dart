import 'package:flutter/material.dart';

class TablesView extends StatefulWidget {
  const TablesView({super.key});

  @override
  State<TablesView> createState() => _TablesViewState();
}

class _TablesViewState extends State<TablesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Растворимость'),
            Tab(text: 'Электродные потенциалы'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _SolubilityTable(),
              _ElectrodePotentialsTable(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SolubilityTable extends StatelessWidget {
  const _SolubilityTable();
  @override
  Widget build(BuildContext context) {
    final rows = const [
      ['Вещество','Растворимость (в воде)'],
      ['NaCl','Растворим'],
      ['KNO3','Растворим'],
      ['NH4Cl','Растворим'],
      ['AgCl','Нерастворим'],
      ['PbCl2','Малорастворим'],
      ['BaSO4','Нерастворим'],
      ['SrSO4','Нерастворим'],
      ['CaCO3','Плохо растворим'],
      ['Ag2CO3','Нерастворим'],
    ];
    return _SimpleTable(rows: rows);
  }
}

class _ElectrodePotentialsTable extends StatelessWidget {
  const _ElectrodePotentialsTable();
  @override
  Widget build(BuildContext context) {
    final rows = const [
      ['Полуреакция','E⁰, В'],
      ['Li⁺ + e⁻ = Li','-3.04'],
      ['K⁺ + e⁻ = K','-2.93'],
      ['Mg²⁺ + 2e⁻ = Mg','-2.37'],
      ['Al³⁺ + 3e⁻ = Al','-1.66'],
      ['Zn²⁺ + 2e⁻ = Zn','-0.76'],
      ['Fe²⁺ + 2e⁻ = Fe','-0.44'],
      ['Ni²⁺ + 2e⁻ = Ni','-0.25'],
      ['H⁺ + e⁻ = 1/2 H2','0.00'],
      ['Cu²⁺ + 2e⁻ = Cu','+0.34'],
      ['Ag⁺ + e⁻ = Ag','+0.80'],
      ['Cl2 + 2e⁻ = 2Cl⁻','+1.36'],
    ];
    return _SimpleTable(rows: rows);
  }
}

class _SimpleTable extends StatelessWidget {
  final List<List<String>> rows;
  const _SimpleTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final header = rows.first;
    final data = rows.skip(1).toList();
    return SingleChildScrollView(
      child: DataTable(
        columns: header.map((h)=> DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
        rows: data.map((r)=> DataRow(cells: r.map((c)=> DataCell(Text(c))).toList())).toList(),
      ),
    );
  }
}


