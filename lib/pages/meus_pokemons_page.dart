import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import 'detalhes_meus_pokemons_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MeusPokemonsPage extends StatefulWidget {
  @override
  _MeusPokemonsPageState createState() => _MeusPokemonsPageState();
}

class _MeusPokemonsPageState extends State<MeusPokemonsPage> {
  List<Pokemon> pokemonsCapturados = [];

  @override
  void initState() {
    super.initState();
    _carregarPokemonsCapturados();
  }

  // Função responsável por carregar os Pokémons capturados do SharedPreferences e da API
  Future<void> _carregarPokemonsCapturados() async {
    final prefs = await SharedPreferences.getInstance();
    final capturadosIds = prefs.getStringList('meus_pokemons') ?? [];

    List<Pokemon> pokemonsTemp =
        []; // Lista temporária para armazenar os Pokémons capturados

    // Busca detalhes de cada Pokémon capturado pelo ID
    for (String id in capturadosIds) {
      Pokemon? pokemon =
          await _fetchPokemonById(id); // Obtendo os detalhes do Pokémon pelo ID
      if (pokemon != null) {
        pokemonsTemp.add(
            pokemon); // Adiciona o Pokémon à lista temporária se encontrado
      }
    }

    setState(() {
      pokemonsCapturados =
          pokemonsTemp; // Atualiza o estado do widget com a lista de Pokémons
    });
  }

  // Função que busca os dados de um Pokémon pelo ID
  Future<Pokemon?> _fetchPokemonById(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Tenta carregar o Pokémon do cache local primeiro
    String? pokemonJson = prefs.getString('pokemon_$id');
    if (pokemonJson != null) {
      final data = json.decode(pokemonJson); // Decodifica o JSON do cache
      return Pokemon.fromJson(data); // Retorna o Pokémon a partir do JSON
    }

    // se o cache não tenha o dado, faz a requisição na API
    final response =
        await http.get(Uri.parse('http://192.168.1.69:3000/pokemons/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica o JSON da resposta
      await prefs.setString(
          'pokemon_$id', json.encode(data)); // Armazena os dados no cache local
      return Pokemon.fromJson(data); // Retorna o Pokémon a partir do JSON
    } else {
      print(
          'Falha ao carregar o Pokémon de ID $id'); // Caso haja falha na requisição, imprime um erro
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Meus Pokémons',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 165, 177),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: pokemonsCapturados
            .length, // Número de itens na grid, baseado na lista de Pokémons capturados
        itemBuilder: (context, index) {
          final pokemon = pokemonsCapturados[
              index]; // Obtém o Pokémon da lista baseado no índice
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetalhesMeusPokemonPage(pokemon: pokemon),
                ),
              );
            },
            child: Card(
              color: const Color.fromARGB(255, 19, 30, 47),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagem do Pokémon
                  CachedNetworkImage(
                    imageUrl:
                        'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/sprites/${pokemon.id.toString().padLeft(3, '0')}MS.png', // URL da imagem do Pokémon
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 8), // Espaçamento entre a imagem e o nome
                  Wrap(
                    spacing: 8.0,
                    children: [
                      Chip(
                        label: Text(
                          pokemon.englishName,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color.fromARGB(
                            255, 1, 165, 177), // Cor de fundo do Chip
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
