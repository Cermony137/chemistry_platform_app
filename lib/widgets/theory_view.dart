import 'package:flutter/material.dart';

class TheoryView extends StatelessWidget {
  const TheoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = <_Topic>[
      _Topic('Основные законы и понятия', [
        'Закон сохранения массы: Σm(реагенты) = Σm(продукты).',
        'Закон кратных и постоянных отношений (Пруст, Дальтон).',
        'Количество вещества: n = m/M; число частиц: N = n·NA.',
        'Мольная доля: x(i) = n(i) / Σn.',
        'Массовая доля: ω = m(компонента)/m(смеси).',
      ]),
      _Topic('Связи и строение', [
        'Ионная, ковалентная (полярная/неполярная), металлическая связь.',
        'Электроотрицательность (по Полингу) и полярность связи.',
        'Гибридизация: sp, sp2, sp3; геометрии: линейная, плоская, тетраэдр.',
        'Формальный заряд: FC = валентные − несв.электроны − 1/2(св.электроны).',
      ]),
      _Topic('Стехиометрия и расчёты', [
        'Алгоритм: записать формулы → балансировка → молярные соотношения → пропорции.',
        'Идеальный газ: PV = nRT; 22.4 л при н.у. для 1 моль.',
        'Закон Авогадро: равные объёмы газов при одинаковых T и P содержат одинаковое число молекул.',
        'Выход реакции: η = m_факт / m_теор · 100%.',
      ]),
      _Topic('Электрохимия и кинетика', [
        'Стандартный ЭДС: E°яч = E°кат − E°ан; ΔG° = −nF E°.',
        'Правило знаков: катод — восстановление (+), анод — окисление (−).',
        'Кинетика: v = k·[A]^α·[B]^β; уравнение Аррениуса k = A·e^(−Ea/RT).',
      ]),
    ];

    return ListView(
      children: topics.map((t) => _TopicTile(topic: t)).toList(),
    );
  }
}

class _Topic {
  final String title; final List<String> bullets;
  _Topic(this.title, this.bullets);
}

class _TopicTile extends StatelessWidget {
  final _Topic topic; const _TopicTile({required this.topic});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: topic.bullets.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• '), Expanded(child: Text(b)),
          ]),
        )).toList(),
      ),
    );
  }
}


