import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pokemon.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database?
      _database; // Instância do banco de dados, inicializada como nula

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null)
      return _database!; // Retorna o banco de dados se já estiver inicializado
    _database =
        await _initDatabase(); // Inicializa o banco de dados se for nulo
    return _database!;
  }

  // Método para inicializar o banco de dados
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(
        path, 'pokedex.db'); // Cria o caminho para o banco de dados Pokedex
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Criando a tabela dos pokemons quando o banco de dados é criado pela primeira vez
        await db.execute('''
          CREATE TABLE pokemons(
            id TEXT PRIMARY KEY, 
            englishName TEXT, 
            japaneseName TEXT, 
            chineseName TEXT,
            frenchName TEXT, 
            types TEXT, 
            hp INTEGER, 
            attack INTEGER, 
            defense INTEGER, 
            spAttack INTEGER, 
            spDefense INTEGER,
            speed INTEGER
          )
        ''');
      },
    );
  }

  // Método para inserir um Pokémon no banco de dados
  Future<void> insertPokemon(Pokemon pokemon) async {
    final db = await database; // Obtém a instância do banco de dados
    await db.insert(
      'pokemons', // Nome da tabela
      pokemon
          .toMap(), // Mapeia o Pokémon para um formato compatível com o banco de dados
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Substitui o registro em caso de conflito
    );
  }

// Método para recuperar todos os Pokémons do banco de dados em ordem crescente de ID
  Future<List<Pokemon>> getPokemons() async {
    final db = await database; // Obtém a instância do banco de dados
    final List<Map<String, dynamic>> maps = await db.query(
      'pokemons',
      orderBy:
          'id ASC', // Ordena os resultados pelo campo 'id' em ordem crescente
    );

    // Mapeia os registros para uma lista de objetos Pokémon
    return List.generate(maps.length, (i) {
      return Pokemon(
        id: maps[i]['id'],
        englishName: maps[i]['englishName'],
        japaneseName: maps[i]['japaneseName'],
        chineseName: maps[i]['chineseName'],
        frenchName: maps[i]['frenchName'],
        types: maps[i]['types']
            .split(','), // Converte a string de tipos para lista
        hp: maps[i]['hp'],
        attack: maps[i]['attack'],
        defense: maps[i]['defense'],
        spAttack: maps[i]['spAttack'],
        spDefense: maps[i]['spDefense'],
        speed: maps[i]['speed'],
      );
    });
  }
}
