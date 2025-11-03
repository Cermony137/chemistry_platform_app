import 'package:flutter/material.dart';

class PracticumView extends StatelessWidget {
  const PracticumView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Group(title: 'Техника безопасности', items: [
          'Индивидуальная защита: очки, перчатки, халат.',
          'Работа в вытяжном шкафу с летучими/токсичными веществами.',
          'Запрещено: pipetting by mouth; хранение еды на рабочем месте.',
          'Порядок ликвидации проливов кислот/щелочей (нейтрализация).',
        ]),
        _Group(title: 'Методики лабораторных работ', items: [
          'Определение pH: бумажные индикаторы, универсальный индикатор, pH-метр (калибровка).',
          'Кислотно-основное титрование: burette rinse, мениск, выбор индикатора (фенолфталеин/метиловый оранжевый).',
          'Гравиметрический анализ: осаждение, промывание, высушивание и взвешивание осадка.',
        ]),
        _Group(title: 'Качественные реакции на ионы', items: [
          'Ag⁺ + Cl⁻ → AgCl↓ (белый); растворяется в NH3(aq).',
          'Ba²⁺ + SO₄²⁻ → BaSO₄↓ (белый, нерастворимый).',
          'Fe³⁺ + 3OH⁻ → Fe(OH)₃↓ (бурый).',
          'Cu²⁺ + 2OH⁻ → Cu(OH)₂↓ (голубой).',
        ]),
        _Group(title: 'Виртуальные эксперименты', items: [
          'Симуляция перегонки: выбор насадок, контроль температуры (заглушка).',
        ]),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  final String title; final List<String> items;
  const _Group({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: items.map((t)=> ListTile(title: Text(t))).toList(),
      ),
    );
  }
}


