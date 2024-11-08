import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';

class DetalhesPokemonPage extends StatelessWidget {
  final Pokemon pokemon;

  const DetalhesPokemonPage({Key? key, required this.pokemon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          pokemon.englishName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 165, 177),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bordas arredondadas
          ),
          color: const Color.fromARGB(255, 19, 30, 47),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Espaçamento interno
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png', // URL da imagem do Pokémon
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        CircularProgressIndicator(), // Indicador de carregamento
                    errorWidget: (context, url, error) => Icon(Icons
                        .error), // Ícone de erro caso a imagem não carregue
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  pokemon.englishName,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: pokemon.types.map((type) {
                    return Chip(
                      label: Text(
                        type,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color.fromARGB(255, 1, 165, 177),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                _buildStatRow('HP', pokemon.hp.toString()),
                _buildStatRow('Ataque', pokemon.attack.toString()),
                _buildStatRow('Defesa', pokemon.defense.toString()),
                _buildStatRow('Velocidade', pokemon.speed.toString()),
                _buildStatRow('Especial Ataque', pokemon.spAttack.toString()),
                _buildStatRow('Especial Defesa', pokemon.spDefense.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Função para exibir o título e o valor de cada atributo
  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
