import 'package:flutter/material.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _ToolTile(title: 'Конвертер единиц', subtitle: 'моль ↔ грамм, объём ↔ количество'),
        _ToolTile(title: 'Работа с формулами', subtitle: 'Подстановка значений, быстрые расчёты'),
        _ToolTile(title: 'Поиск по справочнику', subtitle: 'Единый индекс по разделам'),
        _ToolTile(title: 'Настройки отображения', subtitle: 'Тема, размер шрифта, сетка'),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  final String title; final String subtitle;
  const _ToolTile({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: (){},
    );
  }
}


