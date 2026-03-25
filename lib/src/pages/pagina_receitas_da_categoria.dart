import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/receita.dart';
import '../controllers/receitas_controlador.dart';
import 'pagina_detalhes_receita.dart';

class PaginaReceitasDaCategoria extends StatefulWidget {
  final String categoriaNome;

  const PaginaReceitasDaCategoria({
    super.key,
    required this.categoriaNome,
  });

  @override
  State<PaginaReceitasDaCategoria> createState() =>
      _PaginaReceitasDaCategoriaState();
}

class _PaginaReceitasDaCategoriaState
    extends State<PaginaReceitasDaCategoria> {
  bool carregando = true;
  List receitasApi = [];

  @override
  void initState() {
    super.initState();
    carregarReceitas();
  }

  Future<void> carregarReceitas() async {
    final url = Uri.parse(
      "https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.categoriaNome}",
    );

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      receitasApi = json["meals"];
    }

    setState(() => carregando = false);
  }

  Receita converter(Map item) {
    return Receita(
      id: item["idMeal"],
      nome: item["strMeal"],
      categoria: widget.categoriaNome,
      instrucoes: "Clique para ver o modo de preparo.",
      miniatura: item["strMealThumb"],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<ReceitasControlador>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EC),

      appBar: AppBar(
        title: Text(widget.categoriaNome),
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: receitasApi.length,
              itemBuilder: (_, i) {
                final receita = converter(receitasApi[i]);

                // 🔥 TRADUÇÃO
                final traduzida = controlador.getTraducao(receita.id);
                final nome = traduzida?.nomePt ?? receita.nome;

                return _CardReceita(
                  receita: receita,
                  nomeExibicao: nome,
                );
              },
            ),
    );
  }
}

class _CardReceita extends StatelessWidget {
  final Receita receita;
  final String nomeExibicao;

  const _CardReceita({
    required this.receita,
    required this.nomeExibicao,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaginaDetalhesReceita(receita: receita),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🔥 HERO (animação)
            Hero(
              tag: receita.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: Image.network(
                  receita.miniatura,
                  width: 120,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // TEXTO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  nomeExibicao, // ✅ traduzido
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}