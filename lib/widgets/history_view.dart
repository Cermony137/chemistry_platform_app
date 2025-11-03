import 'package:flutter/material.dart';

class ChemHistoryView extends StatelessWidget {
  const ChemHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ['Антуан Лавуазье','Закон сохранения массы (XVIII век)'],
      ['Джон Дальтон','Атомная теория (начало XIX века)'],
      ['Юстус Либих','Органический анализ и теория радикалов'],
      ['Дмитрий Менделеев','Периодический закон и таблица (1869)'],
      ['Мария Кюри','Радиоактивность, полоний и радий'],
      ['Гилберт Льюис','Электронные пары и валентность'],
      ['Лайнус Полинг','Природа химической связи'],
    ];
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i){
        final e = items[i];
        return ListTile(
          leading: CircleAvatar(child: Text(e[0][0])),
          title: Text(e[0]),
          subtitle: Text(e[1]),
        );
      },
    );
  }
}


