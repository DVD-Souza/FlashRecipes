class ReceitaTraduzida {
  final String idReceita;
  final String nomePt;
  final String categoriaPt;
  final String instrucoesPt;

  ReceitaTraduzida({
    required this.idReceita,
    required this.nomePt,
    required this.categoriaPt,
    required this.instrucoesPt,
  });

  Map<String, dynamic> toMap() {
    return {
      "idReceita": idReceita,
      "nomePt": nomePt,
      "categoriaPt": categoriaPt,
      "instrucoesPt": instrucoesPt,
    };
  }

  factory ReceitaTraduzida.fromMap(Map<String, dynamic> map) {
    return ReceitaTraduzida(
      idReceita: map["idReceita"],
      nomePt: map["nomePt"],
      categoriaPt: map["categoriaPt"],
      instrucoesPt: map["instrucoesPt"],
    );
  }
}