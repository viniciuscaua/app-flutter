import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

class EncontroDiarioPage extends StatefulWidget {
  @override
  _EncontroDiarioPageState createState() => _EncontroDiarioPageState();
}

class _EncontroDiarioPageState extends State<EncontroDiarioPage> {
  Pokemon? pokemonSorteado;
  String? mensagemErro;
  bool pokemonCapturadoHoje = false;

  @override
  void initState() {
    super.initState();
    _verificarCapturaHoje();
  }

  Future<void> _verificarCapturaHoje() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaData = prefs.getString('ultima_data_encontro');
    final dataHoje = DateTime.now().toIso8601String().substring(0, 10);

    // Verifica se a data de hoje é a mesma da última captura registrada
    if (ultimaData == dataHoje) {
      // flag para verificar se o Pokémon foi capturado hoje
      pokemonCapturadoHoje = prefs.getBool('pokemon_capturado_hoje') ?? false;
    } else {
      // Reseta a flag para um novo dia
      await prefs.setBool('pokemon_capturado_hoje', false);
      pokemonCapturadoHoje = false;
    }
    await _gerarPokemonAleatorio();
  }

  Future<void> _gerarPokemonAleatorio() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaData = prefs.getString('ultima_data_encontro');
    final dataHoje = DateTime.now().toIso8601String().substring(0, 10);

    // Verifica se é um novo dia para gerar um Pokémon aleatório
    if (ultimaData != dataHoje) {
      final pokemons = await _buscarPokemons();
      if (pokemons.isNotEmpty) {
        // Gera um índice aleatório para selecionar um Pokémon
        final randomIndex = (pokemons.length *
                (DateTime.now().microsecondsSinceEpoch % 1000) /
                1000)
            .floor();
        pokemonSorteado = pokemons[randomIndex]; // Define o Pokémon sorteado
        await prefs.setString('ultima_data_encontro', dataHoje);
        await prefs.setString(
            'pokemon_encontrado', pokemonSorteado!.id.toString());
      }
    } else {
      // Caso seja o mesmo dia, carrega o Pokémon salvo anteriormente
      final pokemonId = prefs.getString('pokemon_encontrado');
      if (pokemonId != null) {
        final pokemons = await _buscarPokemons();
        pokemonSorteado = pokemons
            .firstWhere((pokemon) => pokemon.id.toString() == pokemonId);
      }
    }
    setState(() {});
  }

  // Função para buscar a lista de Pokémon da API
  Future<List<Pokemon>> _buscarPokemons() async {
    final response = await http
        .get(Uri.parse('https://f8b4-177-20-136-252.ngrok-free.app/pokemons'));

    if (response.statusCode == 200) {
      // Decodifica a resposta e mapeia os dados para uma lista de Pokémon
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Pokemon.fromJson(data)).toList();
    } else {
      throw Exception('Falha ao carregar Pokémon');
    }
  }

  // Função para capturar o Pokémon do dia
  void _capturarPokemon() async {
    final prefs = await SharedPreferences.getInstance();
    final pokemonsCapturados = prefs.getStringList('meus_pokemons') ?? [];

    if (pokemonsCapturados.length >= 6) {
      setState(() {
        mensagemErro =
            'Você já capturou 6 Pokémons. Não é possível capturar mais.';
      });
    } else {
      // Adiciona o Pokémon capturado à lista e salva no armazenamento local
      pokemonsCapturados.add(pokemonSorteado!.id.toString());
      await prefs.setStringList('meus_pokemons', pokemonsCapturados);
      await prefs.setBool(
          'pokemon_capturado_hoje', true); // Marca como capturado
      setState(() {
        pokemonCapturadoHoje = true;
        mensagemErro = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Encontro Diário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 165, 177),
      ),
      body: Center(
        child: pokemonSorteado != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: const Color.fromARGB(255, 19, 30, 47),
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Pokémon Encontrado!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Card(
                    color: const Color.fromARGB(255, 19, 30, 47),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.network(
                            'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemonSorteado!.id.toString().padLeft(3, '0')}.png',
                            height: 150,
                            width: 150,
                          ),
                          SizedBox(height: 16),
                          Text(
                            pokemonSorteado!.englishName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            children: pokemonSorteado!.types.map((type) {
                              return Chip(
                                label: Text(
                                  type,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 1, 165, 177),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          // Exibe as estatísticas do Pokémon como chips
                          Wrap(
                            spacing: 8.0,
                            children: [
                              Chip(
                                label: Text(
                                  'HP: ${pokemonSorteado!.hp}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 1, 165, 177),
                              ),
                              Chip(
                                label: Text(
                                  'Ataque: ${pokemonSorteado!.attack}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 1, 165, 177),
                              ),
                              Chip(
                                label: Text(
                                  'Defesa: ${pokemonSorteado!.defense}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 1, 165, 177),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  if (!pokemonCapturadoHoje) // Exibe o botão "Capturar" caso não tenha sido capturado hoje
                    ElevatedButton(
                      onPressed: _capturarPokemon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 1, 165, 177),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        'Capturar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // Exibe a mensagem de erro caso exista
                  if (mensagemErro != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        mensagemErro!,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                ],
              )
            : CircularProgressIndicator(), // Indicador de carregamento enquanto o Pokémon é gerado
      ),
    );
  }
}
