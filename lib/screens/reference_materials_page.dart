import 'package:flutter/material.dart';
import 'package:chemistry_platform_app/widgets/periodic_table.dart';
import 'package:chemistry_platform_app/widgets/reference_tables.dart';
import 'package:chemistry_platform_app/widgets/theory_view.dart';
import 'package:chemistry_platform_app/widgets/practicum_view.dart';
import 'package:chemistry_platform_app/widgets/preparation_view.dart';
import 'package:chemistry_platform_app/widgets/history_view.dart';
import 'package:chemistry_platform_app/widgets/tools_view.dart';
import 'package:chemistry_platform_app/widgets/study_module.dart';

enum RefSection {
  periodic,
  theory,
  practicum,
  tables,
  preparation,
  history,
  tools,
}

class ReferenceMaterialsPage extends StatefulWidget {
  const ReferenceMaterialsPage({super.key});

  @override
  State<ReferenceMaterialsPage> createState() => _ReferenceMaterialsPageState();
}

class _ReferenceMaterialsPageState extends State<ReferenceMaterialsPage> {
  RefSection? _currentSection;
  final List<String> _breadcrumbs = ['Справочные материалы'];
  final TextEditingController _searchController = TextEditingController();
  final List<String> _history = []; // простая история просмотров названий
  final Set<String> _favorites = {}; // избранное по ключам материалов
  _Entry? _openedMaterial; // текущий открытый материал на полный экран

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочные материалы'),
        actions: [
          IconButton(
            tooltip: 'Избранное',
            onPressed: () => _openFavoritesBottomSheet(context),
            icon: const Icon(Icons.bookmark),
          ),
          IconButton(
            tooltip: 'История',
            onPressed: () => _openHistoryBottomSheet(context),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBreadcrumbs(),
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _openedMaterial != null
                  ? _buildMaterialContent(_openedMaterial!)
                  : (_searchController.text.trim().isNotEmpty
                      ? _buildGlobalSearchResults()
                      : const StudyModule()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          ..._breadcrumbs.asMap().entries.expand((e) {
            final idx = e.key; final label = e.value;
            final isLast = idx == _breadcrumbs.length - 1;
            return [
              GestureDetector(
                onTap: !isLast ? _goRoot : null,
        child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                    color: isLast ? Colors.black87 : Colors.blue,
                  ),
                ),
              ),
              if (!isLast) const Text('→', style: TextStyle(color: Colors.grey)),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск по справочнику',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () { setState(() { _searchController.clear(); }); },
                ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSectionGrid() {
    final cards = <_SectionCardData>[
      _SectionCardData(RefSection.periodic, '🎯 Периодическая система', Icons.grid_on),
      _SectionCardData(RefSection.theory, '📚 Теория', Icons.menu_book),
      _SectionCardData(RefSection.practicum, '🔬 Практикум', Icons.science),
      _SectionCardData(RefSection.tables, '📊 Таблицы', Icons.table_chart),
      _SectionCardData(RefSection.preparation, '🎓 Подготовка', Icons.school),
      _SectionCardData(RefSection.history, '📖 История', Icons.auto_stories),
      _SectionCardData(RefSection.tools, '🛠 Инструменты', Icons.handyman),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final data = cards[index];
          return _SectionCard(
            title: data.title,
            icon: data.icon,
            onTap: () => _openSection(data.section),
          );
        },
      ),
    );
  }

  Widget _buildGlobalSearchResults(){
    final q = _searchController.text.trim().toLowerCase();
    // Собираем все материалы из всех разделов
    final all = <Map<String,String>>[]; // {section,title,subtitle}
    for(final s in RefSection.values){
      for(final g in _sectionGroups(s)){
        for(final e in g.entries){
          final title = e.title; final sub = e.subtitle ?? '';
          if(title.toLowerCase().contains(q) || sub.toLowerCase().contains(q)){
            all.add({'section': _sectionTitle(s), 'title': title, 'subtitle': sub});
          }
        }
      }
    }
    if (all.isEmpty){
      return const Center(child: Text('Ничего не найдено'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: all.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i){
        final it = all[i];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(it['title']!),
          subtitle: Text('${it['section']} • ${it['subtitle'] ?? ''}'),
          onTap: (){
            // Переходим в соответствующий раздел и открываем материал
            final section = RefSection.values.firstWhere((s)=> _sectionTitle(s) == it['section']);
            setState((){ _currentSection = section; _breadcrumbs..clear()..addAll(['Справочные материалы', _sectionTitle(section)]); });
            _openMaterial(_Entry(it['title']!, subtitle: it['subtitle']));
          },
        );
      },
    );
  }

  Widget _buildSectionContent(RefSection section) {
    final filter = _searchController.text.trim().toLowerCase();

    List<_EntryGroup> groups = _sectionGroups(section);
    if (filter.isNotEmpty) {
      groups = groups.map((g) => g.filter(filter)).where((g) => g.entries.isNotEmpty).toList();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListView(
        children: [
          Text(_sectionTitle(section), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _SectionOverview(text: _sectionOverview(section)),
          const SizedBox(height: 12),
          ...groups.map((g) => _ExpandableGroup(
                title: g.title,
                children: g.entries.map((e) => _MaterialTile(
                  title: e.title,
                  subtitle: e.subtitle,
                  onOpen: () => _openMaterial(e),
                  isFavorite: _favorites.contains(e.key),
                  onToggleFavorite: () => setState(() {
                    if (_favorites.contains(e.key)) _favorites.remove(e.key); else _favorites.add(e.key);
                  }),
                )).toList(),
              )),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _goRoot,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Назад к разделам'),
          ),
        ],
      ),
    );
  }

  void _openSection(RefSection s) {
    setState(() {
      _currentSection = s;
      _openedMaterial = null;
      _breadcrumbs..clear()..addAll(['Справочные материалы', _sectionTitle(s)]);
    });
  }

  void _goRoot() {
    setState(() {
      _currentSection = null;
      _openedMaterial = null;
      _breadcrumbs..clear()..add('Справочные материалы');
    });
  }

  void _openMaterial(_Entry e) {
    // Открываем материал на полный экран внутри вкладки
    setState(() {
      _history.insert(0, e.title); if (_history.length > 30) _history.removeLast();
      _openedMaterial = e;
      if (_breadcrumbs.length == 2) {
        _breadcrumbs.add(e.title);
      } else {
        _breadcrumbs..clear()..addAll(['Справочные материалы', if(_currentSection!=null) _sectionTitle(_currentSection!), e.title]);
      }
    });
  }

  void _openFavoritesBottomSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Избранное', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_favorites.isEmpty) const Text('Пока пусто')
            else ..._favorites.map((k)=>Text('• $k')),
          ],
        ),
      ),
    );
  }

  void _openHistoryBottomSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('История', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_history.isEmpty) const Text('Пока пусто')
            else ..._history.take(20).map((t)=>Text('• $t')),
          ],
        ),
      ),
    );
  }

  List<_EntryGroup> _sectionGroups(RefSection s){
    switch (s) {
      case RefSection.periodic:
        return [
          _EntryGroup('Интерактивная таблица', [
            _Entry('Периодическая система', subtitle: 'Интерактивная таблица и фильтры'),
            _Entry('Карточки элементов', subtitle: 'Свойства, изотопы, электронные конфигурации'),
          ]),
          _EntryGroup('Визуализации', [
            _Entry('Периодические закономерности'),
          ]),
        ];
      case RefSection.theory:
        return [
          _EntryGroup('Основы', [
            _Entry('Основные законы и понятия'),
            _Entry('Типы химических связей и реакций'),
            _Entry('Стехиометрия и расчёты'),
            _Entry('Электрохимия и кинетика'),
          ]),
        ];
      case RefSection.practicum:
        return [
          _EntryGroup('Методики', [
            _Entry('Лабораторные работы'),
            _Entry('Оборудование и ТБ'),
            _Entry('Качественные реакции на ионы'),
            _Entry('Виртуальные эксперименты'),
          ]),
        ];
      case RefSection.tables:
        return [
          _EntryGroup('Таблицы', [
            _Entry('Растворимость веществ'),
            _Entry('Физико-химические константы'),
            _Entry('Стандартные электродные потенциалы'),
            _Entry('Термодинамические данные'),
          ]),
        ];
      case RefSection.preparation:
        return [
          _EntryGroup('Подготовка', [
            _Entry('Типовые задачи ЕГЭ/ОГЭ'),
            _Entry('Алгоритмы решения'),
            _Entry('Тесты и проверка знаний'),
            _Entry('Частые ошибки'),
          ]),
        ];
      case RefSection.history:
        return [
          _EntryGroup('История', [
            _Entry('Великие химики и открытия'),
            _Entry('История элементов'),
            _Entry('Развитие химической науки'),
            _Entry('Интересные факты'),
          ]),
        ];
      case RefSection.tools:
        return [
          _EntryGroup('Инструменты', [
            _Entry('Конвертеры единиц'),
            _Entry('Работа с формулами'),
            _Entry('Поиск по справочнику'),
            _Entry('Настройки отображения'),
          ]),
        ];
    }
  }

  String _sectionTitle(RefSection s){
    switch (s) {
      case RefSection.periodic: return '🎯 Периодическая система';
      case RefSection.theory: return '📚 Теория';
      case RefSection.practicum: return '🔬 Практикум';
      case RefSection.tables: return '📊 Таблицы';
      case RefSection.preparation: return '🎓 Подготовка';
      case RefSection.history: return '📖 История';
      case RefSection.tools: return '🛠 Инструменты';
    }
  }

  String _sectionOverview(RefSection s){
    switch (s) {
      case RefSection.periodic:
        return 'Интерактивная таблица Менделеева с поиском по символу/названию, фильтрами по периодам. Карточки элементов содержат основные свойства.';
      case RefSection.theory:
        return 'Базовые теоретические темы: законы, химическая связь и строение, стехиометрия и расчёты, электрохимия и кинетика.';
      case RefSection.practicum:
        return 'Методики лабораторных работ, техника безопасности и качественные реакции. Удобные чек‑листы перед началом эксперимента.';
      case RefSection.tables:
        return 'Сводные таблицы: растворимость, стандартные электродные потенциалы и др. Для быстрого поиска справочных данных.';
      case RefSection.preparation:
        return 'Подготовка к ЕГЭ/ОГЭ: типовые задачи, алгоритмы решения, тесты и список частых ошибок.';
      case RefSection.history:
        return 'Ключевые фигуры и вехи развития химии: короткие справки и связанный контекст.';
      case RefSection.tools:
        return 'Инструменты: конвертеры единиц, работа с формулами, поиск по справочнику, настройки отображения.';
    }
  }

  Widget _buildMaterialContent(_Entry e){
    Widget body;
    if (e.key == 'Периодическая система' || e.key == 'Карточки элементов') {
      body = const PeriodicTableView();
    } else if (e.key == 'Растворимость веществ' || e.key == 'Стандартные электродные потенциалы' || e.key == 'Физико-химические константы' || e.key == 'Термодинамические данные') {
      body = const TablesView();
    } else if (e.key == 'Основные законы и понятия' || e.key == 'Типы химических связей и реакций' || e.key == 'Стехиометрия и расчёты' || e.key == 'Электрохимия и кинетика') {
      body = const TheoryView();
    } else if (e.key == 'Лабораторные работы' || e.key == 'Оборудование и ТБ' || e.key == 'Качественные реакции на ионы' || e.key == 'Виртуальные эксперименты') {
      body = const PracticumView();
    } else if (e.key == 'Типовые задачи ЕГЭ/ОГЭ' || e.key == 'Алгоритмы решения' || e.key == 'Тесты и проверка знаний' || e.key == 'Частые ошибки') {
      body = const PreparationView();
    } else if (e.key == 'Великие химики и открытия' || e.key == 'История элементов' || e.key == 'Развитие химической науки' || e.key == 'Интересные факты') {
      body = const ChemHistoryView();
    } else if (e.key == 'Конвертеры единиц' || e.key == 'Работа с формулами' || e.key == 'Поиск по справочнику' || e.key == 'Настройки отображения') {
      body = const ToolsView();
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [Text(e.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12), const Text('Контент будет добавлен.')],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(e.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              IconButton(
                onPressed: () => setState(() { if (_favorites.contains(e.key)) _favorites.remove(e.key); else _favorites.add(e.key); }),
                icon: Icon(_favorites.contains(e.key) ? Icons.bookmark : Icons.bookmark_border),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: body),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: (){ setState(()=> _openedMaterial = null); if (_breadcrumbs.isNotEmpty) { _breadcrumbs.removeLast(); } },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Назад к разделу'),
          ),
        ],
      ),
    );
  }
}

class _SectionCardData {
  final RefSection section; final String title; final IconData icon;
  _SectionCardData(this.section, this.title, this.icon);
}

class _SectionCard extends StatelessWidget {
  final String title; final IconData icon; final VoidCallback onTap;
  const _SectionCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.blueGrey[700]),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
} 

class _EntryGroup {
  final String title; final List<_Entry> entries;
  _EntryGroup(this.title, this.entries);

  _EntryGroup filter(String q){
    return _EntryGroup(title, entries.where((e)=> e.title.toLowerCase().contains(q) || (e.subtitle?.toLowerCase().contains(q)??false)).toList());
  }
}

class _Entry {
  final String title; final String? subtitle; final String key;
  _Entry(this.title, {this.subtitle}) : key = title;
}

class _ExpandableGroup extends StatelessWidget {
  final String title; final List<Widget> children;
  const _ExpandableGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final String title; final String? subtitle; final VoidCallback onOpen; final bool isFavorite; final VoidCallback onToggleFavorite;
  const _MaterialTile({required this.title, this.subtitle, required this.onOpen, required this.isFavorite, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title),
      subtitle: subtitle==null? null : Text(subtitle!),
      trailing: IconButton(
        icon: Icon(isFavorite? Icons.bookmark : Icons.bookmark_border),
        onPressed: onToggleFavorite,
      ),
      onTap: onOpen,
    );
  }
}

class _SectionOverview extends StatelessWidget {
  final String text; const _SectionOverview({required this.text});
  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
      ),
      child: Text(text),
    );
  }
}
