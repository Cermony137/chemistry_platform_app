import 'package:flutter/material.dart';

class PreparationView extends StatelessWidget {
  const PreparationView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_PrepItem>[
      _PrepItem('Типовые задачи ЕГЭ/ОГЭ', 'Балансировка, стехиометрия, типы реакций, органика'),
      _PrepItem('Алгоритмы решения', 'Стехиометрия, смеси, избыток/недостаток, выход'),
      _PrepItem('Тесты и проверка знаний', 'Короткие квизы по темам с подсказками'),
      _PrepItem('Частые ошибки', 'Коэффициенты, знаки зарядов, ошибки округления, единицы'),
    ];
    return ListView(
      children: [
        ...items.map((it)=> ListTile(title: Text(it.title), subtitle: Text(it.subtitle), trailing: const Icon(Icons.chevron_right))),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Пример задачи', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('Сколько граммов CO2 образуется при сгорании 5.0 г CH4?'),
            SizedBox(height: 6),
            Text('Решение: CH4 + 2O2 = CO2 + 2H2O; M(CH4)=16, M(CO2)=44; n(CH4)=5/16=0.3125 моль; n(CO2)=0.3125 моль; m=0.3125·44≈13.75 г.'),
          ]),
        ),
      ],
    );
  }
}

class _PrepItem {
  final String title; final String subtitle; _PrepItem(this.title, this.subtitle);
}


