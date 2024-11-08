import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import 'detalhes_pokemon_page.dart';
import '../services/database_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({Key? key}) : super(key: key);

  @override
  _PokedexPageState createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  static const _pageSize =
      15; // Tamanho da página para carregamento dos Pokémons
  final PagingController<int, Pokemon> _pagingController = PagingController(
      firstPageKey: 0); // Controlador de paginação para carregamento infinito
  final int totalPokemons = 809; // Total de Pokémons disponíveis para carregar

  @override
  void initState() {
    super.initState();
    // Adiciona listener para a rolagem da página
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPokemons(
          pageKey); // Carrega pokémons de 15 em 15 ao rolar para baixo
    });
  }

  // Função para buscar Pokémons da API e salvar no banco local
  Future<void> _fetchPokemons(int pageKey) async {
    final dbHelper = DatabaseHelper();
    final List<Pokemon> pokemons = []; // Lista de Pokémons para a página atual

    // Carrega os pokémons da API de 15 em 15 com base na página
    for (int id = pageKey * _pageSize + 1;
        id <= (pageKey + 1) * _pageSize;
        id++) {
      if (id > totalPokemons) break;
      final url =
          Uri.parse('https://f8b4-177-20-136-252.ngrok-free.app/pokemons/$id');

      try {
        final response = await http.get(url); // Realiza a requisição HTTP
        if (response.statusCode == 200) {
          final pokemonJson = json.decode(response.body);
          final pokemon = Pokemon.fromJson(
              pokemonJson); // Converte o JSON para objeto Pokémon
          pokemons.add(pokemon); // Adiciona o Pokémon à lista de Pokémons
          await dbHelper.insertPokemon(pokemon);
        }
      } catch (error) {
        print('Erro ao buscar Pokémon: $error');
        break;
      }
    }

    if (pokemons.isEmpty) {
      final localPokemons =
          await dbHelper.getPokemons(); // Obtém Pokémons do banco local
      pokemons.addAll(localPokemons
          .skip(pageKey * _pageSize)
          .take(_pageSize)); // Adiciona Pokémons de forma paginada
    }

    // Verifica se a página atual é a última
    final isLastPage = pokemons.length < _pageSize;
    if (isLastPage) {
      _pagingController.appendLastPage(
          pokemons); // Se for a última página, encerra a paginação
    } else {
      final nextPageKey = pageKey + 1; // Incrementa a chave da próxima página
      _pagingController.appendPage(
          pokemons, nextPageKey); // Adiciona a página atual à lista de páginas
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 1, 165, 177),
      ),
      body: PagedListView<int, Pokemon>(
        // Exibe os Pokémons em uma lista paginada
        pagingController: _pagingController, // Controlador de paginação
        builderDelegate: PagedChildBuilderDelegate<Pokemon>(
          itemBuilder: (context, pokemon, index) => GestureDetector(
            onTap: () {
              // Ao tocar no Pokémon, navega para a tela de detalhes do Pokémon
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesPokemonPage(pokemon: pokemon),
                ),
              );
            },
            child: Card(
              color: const Color.fromARGB(255, 19, 30, 47),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 80,
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl:
                        'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/sprites/${pokemon.id.toString().padLeft(3, '0')}MS.png', // URL da imagem
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(), // Exibe um indicador de carregamento
                    errorWidget: (context, url, error) => Icon(Icons
                        .error), // Exibe um ícone de erro caso a imagem falhe
                  ),
                  title: Text(pokemon.englishName,
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "Tipo: ${pokemon.types.join(', ')}\nHP: ${pokemon.hp} | Ataque: ${pokemon.attack} | Defesa: ${pokemon.defense}",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
