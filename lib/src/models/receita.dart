class Receita {
  final String id;
  final String nome;
  final String categoria;
  final String instrucoes;
  final String miniatura;

  Receita({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.instrucoes,
    required this.miniatura,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json["idMeal"] ?? "",
      nome: json["strMeal"] ?? "",
      categoria: json["strCategory"] ?? "",
      instrucoes: json["strInstructions"] ?? "",
      miniatura: json["strMealThumb"] ?? "",
    );
  }
}