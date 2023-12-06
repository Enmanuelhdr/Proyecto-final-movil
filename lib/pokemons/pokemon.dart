class Pokemon {
  final String name;
  final String url;

  // Constructor que requiere el nombre y la URL del Pokémon
  Pokemon({required this.name, required this.url});

  // Factoría para construir una instancia de Pokemon desde un mapa JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Retorna una nueva instancia de Pokemon con los datos del JSON
    return Pokemon(name: json['name'], url: json['url']);
  }
}

class PokemonDetails {
  final String frontDefault;
  final List<String> abilities;
  final List<Map<String, dynamic>> moves;
  final int weight;

  PokemonDetails({
    required this.frontDefault,
    required this.abilities,
    required this.moves,
    required this.weight,
  });

  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> abilitiesList = json['abilities'];
    final List<dynamic> movesList = json['moves'];

    return PokemonDetails(
      frontDefault: json['sprites']['front_default'],
      abilities: abilitiesList.map<String>((ability) => ability['ability']['name'] as String).toList(),
      moves: movesList.cast<Map<String, dynamic>>(),
      weight: json['weight'],
    );
  }
}
