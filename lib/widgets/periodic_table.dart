import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PeriodicTableView extends StatefulWidget {
  const PeriodicTableView({super.key});

  @override
  State<PeriodicTableView> createState() => _PeriodicTableViewState();
}

class _PeriodicTableViewState extends State<PeriodicTableView> {
  List<_ElementData> _elements = [];
  String _query = '';
  int? _periodFilter; // 1..7/8

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/PeriodicTableJSON.json');
      final data = json.decode(jsonStr);
      final list = (data as List).map((e) => _ElementData.fromJson(e)).toList();
      setState(() { _elements = list; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _elements.where((el) {
      final matchQuery = _query.isEmpty ||
          el.symbol.toLowerCase().contains(_query) ||
          el.name.toLowerCase().contains(_query) ||
          el.atomicNumber.toString() == _query;
      final matchPeriod = _periodFilter == null || el.period == _periodFilter;
      return matchQuery && matchPeriod;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Поиск по символу, названию или номеру',
                ),
                onChanged: (v) => setState(() { _query = v.trim().toLowerCase(); }),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int?>(
              value: _periodFilter,
              hint: const Text('Период'),
              onChanged: (v) => setState(() { _periodFilter = v; }),
              items: <int?>[null,1,2,3,4,5,6,7].map((p) => DropdownMenuItem(
                value: p, child: Text(p==null? 'Все' : p.toString()))).toList(),
            )
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.2,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _ElementCard(data: filtered[index]),
          ),
        ),
      ],
    );
  }
}

class _ElementData {
  final int atomicNumber; final String symbol; final String name; final double? atomicMass; final int? period; final int? group;
  _ElementData(this.atomicNumber, this.symbol, this.name, this.atomicMass, this.period, this.group);
  factory _ElementData.fromJson(Map<String, dynamic> j){
    return _ElementData(
      j['atomicNumber'] is int ? j['atomicNumber'] : int.tryParse('${j['atomicNumber']}') ?? 0,
      '${j['symbol']}',
      '${j['name']}',
      (j['atomicMass'] is num) ? (j['atomicMass'] as num).toDouble() : double.tryParse('${j['atomicMass']}'),
      j['period'] is int ? j['period'] : int.tryParse('${j['period']}'),
      j['group'] is int ? j['group'] : int.tryParse('${j['group']}'),
    );
  }
}

class _ElementCard extends StatelessWidget {
  final _ElementData data; const _ElementCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data.atomicNumber}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const Spacer(),
            Center(child: Text(data.symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            const Spacer(),
            Text(data.name, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context){
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data.symbol} — ${data.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Атомный номер: ${data.atomicNumber}'),
            if (data.atomicMass != null) Text('Атомная масса: ${data.atomicMass}'),
            if (data.period != null) Text('Период: ${data.period}'),
            if (data.group != null) Text('Группа: ${data.group}'),
            const SizedBox(height: 12),
            const Text('Карточка элемента (заглушка для расширенных свойств).'),
          ],
        ),
      ),
    );
  }
}


