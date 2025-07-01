class Element {
  final int atomicNumber;
  final String symbol;
  final String name;
  final String? russianName;
  final double atomicMass;
  final String category;
  final String phase;
  final String? block;
  final String? appearance;
  final double? density;
  final double? melt;
  final double? boil;
  final int? neutrons;
  final int? protons;
  final int? electrons;
  final int? period;
  final int? group;
  final String? imageUrl;
  final String? imageAttribution;
  final String? electronConfiguration;

  const Element({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    this.russianName,
    required this.atomicMass,
    required this.category,
    required this.phase,
    this.block,
    this.appearance,
    this.density,
    this.melt,
    this.boil,
    this.neutrons,
    this.protons,
    this.electrons,
    this.period,
    this.group,
    this.imageUrl,
    this.imageAttribution,
    this.electronConfiguration,
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      atomicNumber: json['number'],
      symbol: json['symbol'],
      name: json['name'],
      russianName: _getRussianName(json['name']),
      atomicMass: json['atomic_mass'] is int
          ? (json['atomic_mass'] as int).toDouble()
          : json['atomic_mass'],
      category: json['category'],
      phase: json['phase'],
      block: json['block'],
      appearance: json['appearance'],
      density: json['density'] is int
          ? (json['density'] as int).toDouble()
          : json['density'],
      melt: json['melt'] is int ? (json['melt'] as int).toDouble() : json['melt'],
      boil: json['boil'] is int ? (json['boil'] as int).toDouble() : json['boil'],
      neutrons: json['neutrons'],
      protons: json['protons'],
      electrons: json['electrons'],
      period: json['period'],
      group: json['group'],
      imageUrl: json['image']?['url'],
      imageAttribution: json['image']?['attribution'],
      electronConfiguration: json['electron_configuration'],
    );
  }

  static String? _getRussianName(String englishName) {
    final Map<String, String> russianNames = {
      'Hydrogen': 'Водород',
      'Helium': 'Гелий',
      'Lithium': 'Литий',
      'Beryllium': 'Бериллий',
      'Boron': 'Бор',
      'Carbon': 'Углерод',
      'Nitrogen': 'Азот',
      'Oxygen': 'Кислород',
      'Fluorine': 'Фтор',
      'Neon': 'Неон',
      'Sodium': 'Натрий',
      'Magnesium': 'Магний',
      'Aluminium': 'Алюминий',
      'Silicon': 'Кремний',
      'Phosphorus': 'Фосфор',
      'Sulfur': 'Сера',
      'Chlorine': 'Хлор',
      'Argon': 'Аргон',
      'Potassium': 'Калий',
      'Calcium': 'Кальций',
      'Scandium': 'Скандий',
      'Titanium': 'Титан',
      'Vanadium': 'Ванадий',
      'Chromium': 'Хром',
      'Manganese': 'Марганец',
      'Iron': 'Железо',
      'Cobalt': 'Кобальт',
      'Nickel': 'Никель',
      'Copper': 'Медь',
      'Zinc': 'Цинк',
      'Gallium': 'Галлий',
      'Germanium': 'Германий',
      'Arsenic': 'Мышьяк',
      'Selenium': 'Селен',
      'Bromine': 'Бром',
      'Krypton': 'Криптон',
      'Rubidium': 'Рубидий',
      'Strontium': 'Стронций',
      'Yttrium': 'Иттрий',
      'Zirconium': 'Цирконий',
      'Niobium': 'Ниобий',
      'Molybdenum': 'Молибден',
      'Technetium': 'Технеций',
      'Ruthenium': 'Рутений',
      'Rhodium': 'Родий',
      'Palladium': 'Палладий',
      'Silver': 'Серебро',
      'Cadmium': 'Кадмий',
      'Indium': 'Индий',
      'Tin': 'Олово',
      'Antimony': 'Сурьма',
      'Iodine': 'Иод',
      'Tellurium': 'Теллур',
      'Xenon': 'Ксенон',
      'Caesium': 'Цезий',
      'Barium': 'Барий',
      'Lanthanum': 'Лантан',
      'Cerium': 'Церий',
      'Praseodymium': 'Празеодим',
      'Neodymium': 'Неодим',
      'Promethium': 'Прометий',
      'Samarium': 'Самарий',
      'Europium': 'Европий',
      'Gadolinium': 'Гадолиний',
      'Terbium': 'Тербий',
      'Dysprosium': 'Диспрозий',
      'Holmium': 'Гольмий',
      'Erbium': 'Эрбий',
      'Thulium': 'Тулий',
      'Ytterbium': 'Иттербий',
      'Lutetium': 'Лютеций',
      'Hafnium': 'Гафний',
      'Tantalum': 'Тантал',
      'Tungsten': 'Вольфрам',
      'Rhenium': 'Рений',
      'Osmium': 'Осмий',
      'Iridium': 'Иридий',
      'Platinum': 'Платина',
      'Gold': 'Золото',
      'Mercury': 'Ртуть',
      'Thallium': 'Таллий',
      'Lead': 'Свинец',
      'Bismuth': 'Висмут',
      'Polonium': 'Полоний',
      'Astatine': 'Астат',
      'Radon': 'Радон',
      'Francium': 'Франций',
      'Radium': 'Радий',
      'Actinium': 'Актиний',
      'Thorium': 'Торий',
      'Protactinium': 'Протактиний',
      'Uranium': 'Уран',
      'Neptunium': 'Нептуний',
      'Plutonium': 'Плутоний',
      'Americium': 'Америций',
      'Curium': 'Кюрий',
      'Berkelium': 'Берклий',
      'Californium': 'Калифорний',
      'Einsteinium': 'Эйнштейний',
      'Fermium': 'Фермий',
      'Mendelevium': 'Менделевий',
      'Nobelium': 'Нобелий',
      'Lawrencium': 'Лоуренсий',
      'Rutherfordium': 'Резерфордий',
      'Dubnium': 'Дубний',
      'Seaborgium': 'Сиборгий',
      'Bohrium': 'Борий',
      'Hassium': 'Хассий',
      'Meitnerium': 'Мейтнерий',
      'Darmstadtium': 'Дармштадтий',
      'Roentgenium': 'Рентгений',
      'Copernicium': 'Коперниций',
      'Nihonium': 'Нихоний',
      'Flerovium': 'Флеровий',
      'Moscovium': 'Московий',
      'Livermorium': 'Ливерморий',
      'Tennessine': 'Теннессин',
      'Oganesson': 'Оганесон',
    };
    return russianNames[englishName];
  }
}