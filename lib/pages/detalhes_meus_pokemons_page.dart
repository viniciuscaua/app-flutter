import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/pokemon.dart';

class DetalhesMeusPokemonPage extends StatefulWidget {
  final Pokemon pokemon;

  DetalhesMeusPokemonPage({required this.pokemon});

  @override
  _DetalhesMeusPokemonPageState createState() =>
      _DetalhesMeusPokemonPageState();
}

class _DetalhesMeusPokemonPageState extends State<DetalhesMeusPokemonPage> {
  // Função para soltar o Pokémon da lista de Pokémon capturados
  Future<void> _soltarPokemon() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pokemonsCapturados =
        prefs.getStringList('meus_pokemons') ?? [];

    // Remove o Pokémon da lista de IDs dos Pokémon capturados
    pokemonsCapturados.remove(widget.pokemon.id);
    await prefs.setStringList('meus_pokemons', pokemonsCapturados);

    Navigator.pop(context,
        true); // Retorna à tela anterior e sinaliza que houve uma atualização
  }

  // Função para confirmar o envio do Pokémon com um diálogo de confirmação
  void _confirmarSoltar() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Soltar Pokémon',
      desc: 'Tem certeza de que deseja soltar este Pokémon?',
      btnCancelOnPress: () {}, // Nenhuma ação no botão de cancelamento.
      btnOkOnPress:
          _soltarPokemon, // Chama a função _soltarPokemon quando confirmado
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.pokemon.englishName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 165, 177),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Espaçamento interno da tela
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8,
              margin: EdgeInsets.all(16), // Espaçamento externo do Card.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color.fromARGB(255, 19, 30, 47),
              child: Padding(
                padding:
                    const EdgeInsets.all(16.0), // Espaçamento interno do Card.
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Coluna ajustada ao conteúdo
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${widget.pokemon.id.toString().padLeft(3, '0')}.png',
                        height: 150,
                        width: 150,
                        fit: BoxFit
                            .cover, // Ajusta a imagem para cobrir o espaço.
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons
                            .error), // Ícone de erro se a imagem não for carregada.
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.pokemon.englishName,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: widget.pokemon.types.map((type) {
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
                    // Funções para mostrar as estatísticas do Pokémon com um tamanho de fonte aumentado.
                    _buildStatRow('HP', widget.pokemon.hp.toString(),
                        fontSize: 16),
                    _buildStatRow('Ataque', widget.pokemon.attack.toString(),
                        fontSize: 16),
                    _buildStatRow('Defesa', widget.pokemon.defense.toString(),
                        fontSize: 16),
                    _buildStatRow('Velocidade', widget.pokemon.speed.toString(),
                        fontSize: 16),
                    _buildStatRow(
                        'Especial Ataque', widget.pokemon.spAttack.toString(),
                        fontSize: 16),
                    _buildStatRow(
                        'Especial Defesa', widget.pokemon.spDefense.toString(),
                        fontSize: 16),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16), // Espaçamento para o botão.
            ElevatedButton(
              onPressed: _confirmarSoltar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 165, 177),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text(
                'Soltar Pokémon',
                style: TextStyle(color: Colors.white), // Texto do botão.
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função auxiliar para construir as linhas de estatísticas com nome e valor.
  Widget _buildStatRow(String statName, String statValue,
      {double fontSize = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          statName,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
        Text(
          statValue,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
      ],
    );
  }
}
