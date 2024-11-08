class Pokemon {
  final String id;
  final String englishName;
  final String japaneseName;
  final String chineseName;
  final String frenchName;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int spAttack;
  final int spDefense;
  final int speed;

  Pokemon({
    required this.id,
    required this.englishName,
    required this.japaneseName,
    required this.chineseName,
    required this.frenchName,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
  });

  // Método para criar uma instância de Pokemon a partir de um mapa JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'].toString(), // Convertendo o id pra garantir
      englishName:
          json['name']['english'] ?? '', // Usando fallback para evitar null
      japaneseName: json['name']['japanese'] ?? '',
      chineseName: json['name']['chinese'] ?? '',
      frenchName: json['name']['french'] ?? '',
      types: List<String>.from(json['type'].map((type) => type.toString())),
      hp: json['base']['HP'] ?? 0,
      attack: json['base']['Attack'] ?? 0,
      defense: json['base']['Defense'] ?? 0,
      spAttack: json['base']['Sp. Attack'] ?? 0,
      spDefense: json['base']['Sp. Defense'] ?? 0,
      speed: json['base']['Speed'] ?? 0,
    );
  }

  // Método para converter a instância de Pokemon em um mapa (para salvar no banco de dados).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'englishName': englishName,
      'japaneseName': japaneseName,
      'chineseName': chineseName,
      'frenchName': frenchName,
      'types': types.join(','),
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'spAttack': spAttack,
      'spDefense': spDefense,
      'speed': speed,
    };
  }
}
