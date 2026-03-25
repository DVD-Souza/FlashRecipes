import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/receita.dart';

class ApiReceitasServico {
  final String _url = "https://www.themealdb.com/api/json/v1/1/search.php?s=";

  Future<List<Receita>> buscarReceitas() async {
    final resposta = await http.get(Uri.parse(_url));

    if (resposta.statusCode != 200) {
      throw Exception("Erro ao buscar receitas!");
    }

    final json = jsonDecode(resposta.body);
    final lista = json["meals"] as List;

    return lista.map((e) => Receita.fromJson(e)).toList();
  }
}