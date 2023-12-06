import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/helpers/drawer_navigation.dart';
import 'dart:convert';
import 'package:shop/pokemons/pokemon.dart';

// Pantalla principal de la aplicación que muestra la lista de Pokémon
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon List'),
        backgroundColor: Colors.red,
      ),
      
      drawer: const DrawerNavigation(),
      body: const PokemonList(),
    );
  }
}

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PokemonListState createState() => _PokemonListState();
}

// Estado del widget PokemonList
class _PokemonListState extends State<PokemonList> {
  late Future<List<Pokemon>> futurePokemonList;

  @override
  void initState() {
    super.initState();
    futurePokemonList = fetchPokemonList();
  }

  // Función para obtener la lista de Pokémon desde la API
  Future<List<Pokemon>> fetchPokemonList() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100&offset=0'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((result) => Pokemon.fromJson(result)).toList();
    } else {
      throw Exception('Failed to load Pokémon list');
    }
  }

  // Función para obtener detalles de un Pokémon específico desde la API
  Future<PokemonDetails> fetchPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return PokemonDetails.fromJson(data);
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

   // Muestra un cuadro de diálogo con los detalles del Pokémon
  void _showDetailsDialog(PokemonDetails details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            details.weight.toString(),
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del AlertDialog
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(details.frontDefault),
                  radius: 50.0,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Abilities:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              for (var ability in details.abilities)
                Text(
                  '- $ability',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              const SizedBox(height: 10.0),
              const Text(
                'Moves:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              for (var i = 0; i < 10 && i < details.moves.length; i++)
                Text(
                  '- ${details.moves[i]['move']['name']} - ${details.moves[i]['version_group_details'][0]['version_group']['name']}',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pokemon>>(
      future: futurePokemonList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${index + 1}.png';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5.0,
                child: ListTile(
                  onTap: () {
                    fetchPokemonDetails(snapshot.data![index].url).then((details) {
                      _showDetailsDialog(details);
                    });
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  title: Text(snapshot.data![index].name),
                  subtitle: FutureBuilder<PokemonDetails>(
                    future: fetchPokemonDetails(snapshot.data![index].url),
                    builder: (context, detailsSnapshot) {
                      if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Habilidades: Cargando...');
                      } else if (detailsSnapshot.hasError) {
                        return const Text('Habilidades: Error al cargar');
                      } else {
                        final abilities = detailsSnapshot.data!.abilities.join(', ');
                        return Text('Habilidades: $abilities');
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
