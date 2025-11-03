import 'package:flutter/material.dart';

class StudyTopic {
  final String id;
  final String title;
  final Color color;
  final String emoji;
  final List<StudySubtopic> subtopics;
  const StudyTopic({required this.id, required this.title, required this.color, required this.emoji, required this.subtopics});
}

class StudySubtopic {
  final String id; final String title; final List<StudyLecture> lectures;
  const StudySubtopic({required this.id, required this.title, required this.lectures});
}

class StudyLecture {
  final String id; final String title; final List<String> sections;
  const StudyLecture({required this.id, required this.title, required this.sections});
}

// Цветовая схема из промпта
const _c = {
  '1': Color(0xFF2E7D32),
  '2': Color(0xFF1565C0),
  '3': Color(0xFF6A1B9A),
  '4': Color(0xFFC2185B),
  '5': Color(0xFF00838F),
  '6': Color(0xFFEF6C00),
  '7': Color(0xFF0277BD),
  '8': Color(0xFFD84315),
  '9': Color(0xFF689F38),
  '10': Color(0xFF5D4037),
  '11': Color(0xFF37474F),
  '12': Color(0xFF4A148C),
};

List<StudyTopic> buildDefaultStudyTopics() {
  return [
    StudyTopic(
      id: 'basics', emoji: '🧪', title: 'Основы химии', color: _c['1']!,
      subtopics: [
        const StudySubtopic(id: 'subject', title: 'Предмет и методы химии', lectures: [StudyLecture(id: 'l1', title: 'Введение', sections: ['Определение химии', 'Методы: эксперимент, теоретический анализ'])]),
        const StudySubtopic(id: 'laws', title: 'Основные законы', lectures: [StudyLecture(id: 'l1', title: 'Законы химии', sections: ['Сохранение массы', 'Постоянство состава'])]),
        const StudySubtopic(id: 'classification', title: 'Классификация веществ', lectures: [StudyLecture(id: 'l1', title: 'Типы веществ', sections: ['Простые', 'Сложные'])]),
        const StudySubtopic(id: 'stoich', title: 'Стехиометрия', lectures: [StudyLecture(id: 'l1', title: 'Расчёты', sections: ['n=m/M', 'PV=nRT'])]),
        const StudySubtopic(id: 'nomenclature', title: 'Номенклатура', lectures: [StudyLecture(id: 'l1', title: 'ИUPAC основы', sections: ['Правила именования'])]),
        const StudySubtopic(id: 'solutions', title: 'Растворы и концентрации', lectures: [StudyLecture(id: 'l1', title: 'Концентрации', sections: ['Молярность', 'Массовая доля'])]),
        const StudySubtopic(id: 'acid-base', title: 'Кислотно-основные теории', lectures: [StudyLecture(id: 'l1', title: 'Бренстед-Лоури', sections: ['Кислоты/основания'])]),
        const StudySubtopic(id: 'redox', title: 'ОВР', lectures: [StudyLecture(id: 'l1', title: 'Окисление-восстановление', sections: ['Степени окисления'])]),
      ],
    ),
    StudyTopic(id: 'structure', emoji: '⚛️', title: 'Строение вещества', color: _c['2']!, subtopics: const [
      StudySubtopic(id: 'atom', title: 'Строение атома', lectures: [StudyLecture(id: 'l1', title: 'Атом', sections: ['Ядро и электроны'])]),
      StudySubtopic(id: 'periodic', title: 'Периодическая система', lectures: [StudyLecture(id: 'l1', title: 'Периодические свойства', sections: ['Радиус', 'ЭО'])]),
      StudySubtopic(id: 'cov', title: 'Ковалентная связь', lectures: [StudyLecture(id: 'l1', title: 'Теория Льюиса', sections: ['Электронные пары'])]),
      StudySubtopic(id: 'ionic', title: 'Ионная связь', lectures: [StudyLecture(id: 'l1', title: 'Ионные кристаллы', sections: ['Энергия решётки'])]),
      StudySubtopic(id: 'metal', title: 'Металлическая связь', lectures: [StudyLecture(id: 'l1', title: 'Модель электрона газа', sections: ['Проводимость'])]),
      StudySubtopic(id: 'hbond', title: 'Водородная связь', lectures: [StudyLecture(id: 'l1', title: 'Особенности', sections: ['Сильные межмолекулярные'])]),
      StudySubtopic(id: 'complex', title: 'Комплексные соединения', lectures: [StudyLecture(id: 'l1', title: 'Координация', sections: ['Лиганды'])]),
      StudySubtopic(id: 'crystal', title: 'Кристаллические решётки', lectures: [StudyLecture(id: 'l1', title: 'Типы решёток', sections: ['ГЦК, ОЦК'])]),
    ]),
    StudyTopic(id: 'inorg', emoji: '🔬', title: 'Неорганическая химия', color: _c['3']!, subtopics: const [
      StudySubtopic(id: 's-block', title: 's-блок элементов', lectures: [StudyLecture(id: 'l1', title: 'Щелочные и щелочноземельные металлы', sections: ['Свойства', 'Реакции с водой'])]),
      StudySubtopic(id: 'p-block', title: 'p-блок элементов', lectures: [StudyLecture(id: 'l1', title: 'Галогены и кислород', sections: ['Окислительные свойства'])]),
      StudySubtopic(id: 'd-block', title: 'd-блок (переходные)', lectures: [StudyLecture(id: 'l1', title: 'Комплексообразование', sections: ['Координационное число'])]),
      StudySubtopic(id: 'oxides', title: 'Оксиды и гидроксиды', lectures: [StudyLecture(id: 'l1', title: 'Классификация и реакции', sections: ['Основные, амфотерные, кислотные'])]),
      StudySubtopic(id: 'acids', title: 'Кислоты и соли', lectures: [StudyLecture(id: 'l1', title: 'Сильные/слабые кислоты', sections: ['Диссоциация'])]),
      StudySubtopic(id: 'nitrogen', title: 'Азот и его соединения', lectures: [StudyLecture(id: 'l1', title: 'NH3, HNO3', sections: ['Свойства и получение'])]),
      StudySubtopic(id: 'sulfur', title: 'Сера и её соединения', lectures: [StudyLecture(id: 'l1', title: 'SO2, H2SO4', sections: ['Окисление/восстановление'])]),
      StudySubtopic(id: 'silicon', title: 'Кремний и силикатные материалы', lectures: [StudyLecture(id: 'l1', title: 'SiO2 и стекло', sections: ['Структура и применение'])]),
    ]),
    StudyTopic(id: 'org', emoji: '⚗️', title: 'Органическая химия', color: _c['4']!, subtopics: const [
      StudySubtopic(id: 'hydrocarbons', title: 'Углеводороды', lectures: [StudyLecture(id: 'l1', title: 'Алканы, алкены, алкины', sections: ['Номенклатура', 'Изомерия'])]),
      StudySubtopic(id: 'aromatic', title: 'Ароматические соединения', lectures: [StudyLecture(id: 'l1', title: 'Бензол и производные', sections: ['Правила ориентации'])]),
      StudySubtopic(id: 'alcohols', title: 'Спирты и фенолы', lectures: [StudyLecture(id: 'l1', title: 'Свойства и реакции', sections: ['Окисление, этерификация'])]),
      StudySubtopic(id: 'aldehydes', title: 'Альдегиды и кетоны', lectures: [StudyLecture(id: 'l1', title: 'Карбонильные соединения', sections: ['Реакции присоединения'])]),
      StudySubtopic(id: 'carboxylic', title: 'Карбоновые кислоты и сложные эфиры', lectures: [StudyLecture(id: 'l1', title: 'Кислотность и образование эфиров', sections: ['Эстерификация'])]),
      StudySubtopic(id: 'amines', title: 'Амины и амидные соединения', lectures: [StudyLecture(id: 'l1', title: 'Основность и реакции', sections: ['Ацилирование'])]),
      StudySubtopic(id: 'polymers', title: 'Полимеры', lectures: [StudyLecture(id: 'l1', title: 'Полимеризация и поликонденсация', sections: ['Типы полимеров'])]),
      StudySubtopic(id: 'analysis', title: 'Органический анализ', lectures: [StudyLecture(id: 'l1', title: 'Функциональные группы', sections: ['Качественные реакции'])]),
    ]),
    StudyTopic(id: 'analyt', emoji: '📊', title: 'Аналитическая химия', color: _c['5']!, subtopics: const [
      StudySubtopic(id: 'qual', title: 'Качественный анализ', lectures: [StudyLecture(id: 'l1', title: 'Анионы и катионы', sections: ['Осадочные реакции'])]),
      StudySubtopic(id: 'grav', title: 'Гравиметрический анализ', lectures: [StudyLecture(id: 'l1', title: 'Осаждение и взвешивание', sections: ['Требования к осадкам'])]),
      StudySubtopic(id: 'titr', title: 'Титриметрический анализ', lectures: [StudyLecture(id: 'l1', title: 'Кислотно-основное, окислительно-восстановительное титрование', sections: ['Индикаторы'])]),
      StudySubtopic(id: 'spectro', title: 'Спектральные методы', lectures: [StudyLecture(id: 'l1', title: 'УФ-видимая и ИК-спектроскопия', sections: ['Зоны поглощения'])]),
      StudySubtopic(id: 'chrom', title: 'Хроматография', lectures: [StudyLecture(id: 'l1', title: 'Тонкослойная и ГХ', sections: ['Фактор удерживания'])]),
      StudySubtopic(id: 'electroanal', title: 'Электроаналитические методы', lectures: [StudyLecture(id: 'l1', title: 'Полярография, потенциометрия', sections: ['Электроды сравнения'])]),
    ]),
    StudyTopic(id: 'phys', emoji: '🔥', title: 'Физическая химия', color: _c['6']!, subtopics: const [
      StudySubtopic(id: 'thermo', title: 'Химическая термодинамика', lectures: [StudyLecture(id: 'l1', title: 'Первое и второе начала', sections: ['ΔH, ΔS, ΔG'])]),
      StudySubtopic(id: 'kinetics', title: 'Кинетика', lectures: [StudyLecture(id: 'l1', title: 'Скорость и порядок реакций', sections: ['Уравнение Аррениуса'])]),
      StudySubtopic(id: 'phase', title: 'Фазовые равновесия', lectures: [StudyLecture(id: 'l1', title: 'Диаграммы фаз', sections: ['Тройная точка'])]),
      StudySubtopic(id: 'surface', title: 'Поверхностные явления', lectures: [StudyLecture(id: 'l1', title: 'Адсорбция и ПАВ', sections: ['Изотермы'])]),
      StudySubtopic(id: 'colligative', title: 'Коллигативные свойства', lectures: [StudyLecture(id: 'l1', title: 'Понижение Tзамерзания, повышение Tкипения', sections: ['Растворы'])]),
      StudySubtopic(id: 'cat', title: 'Катализ', lectures: [StudyLecture(id: 'l1', title: 'Гомо- и гетерогенный катализ', sections: ['Механизмы'])]),
    ]),
    StudyTopic(id: 'electro', emoji: '⚡', title: 'Электрохимия', color: _c['7']!, subtopics: const []),
    StudyTopic(id: 'thermo', emoji: '🌡', title: 'Термохимия', color: _c['8']!, subtopics: const []),
    StudyTopic(id: 'bio', emoji: '🧫', title: 'Биохимия', color: _c['9']!, subtopics: const []),
    StudyTopic(id: 'industry', emoji: '🏭', title: 'Промышленная химия', color: _c['10']!, subtopics: const []),
    StudyTopic(id: 'exam', emoji: '🎓', title: 'Экзаменационная подготовка', color: _c['11']!, subtopics: const []),
    StudyTopic(id: 'exp', emoji: '🔍', title: 'Экспериментальная химия', color: _c['12']!, subtopics: const []),
  ];
}


