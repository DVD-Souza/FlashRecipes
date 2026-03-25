import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/receitas_controlador.dart';
import '../controllers/favoritos_controlador.dart';
import '../models/receita.dart';
import '../models/receita_traduzida.dart';

class PaginaDetalhesReceita extends StatefulWidget {
  final Receita receita;

  const PaginaDetalhesReceita({
    super.key,
    required this.receita,
  });

  @override
  State<PaginaDetalhesReceita> createState() =>
      _PaginaDetalhesReceitaState();
}

class _PaginaDetalhesReceitaState extends State<PaginaDetalhesReceita> {

  late Future<ReceitaTraduzida> _future;

  @override
  void initState() {
    super.initState();

    _future = context
        .read<ReceitasControlador>()
        .traduzirReceita(widget.receita);
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosControlador>();
    final original = widget.receita;
    final estaFav = favoritos.estaFavorito(original);

    return Scaffold(
      backgroundColor: Colors.white,

      body: FutureBuilder<ReceitaTraduzida>(
        future: _future,
        builder: (context, snapshot) {

          // 🔄 LOADING
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final traduzida = snapshot.data!;

          return Column(
            children: [

              // 🔥 IMAGEM COM HERO
              Hero(
                tag: original.id,
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    original.miniatura,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 🔥 CONTEÚDO
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 10),

                        // ✅ NOME TRADUZIDO
                        Text(
                          traduzida.nomePt,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ CATEGORIA TRADUZIDA
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0B2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            traduzida.categoriaPt,
                            style: const TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          "Modo de Preparo",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ INSTRUÇÕES TRADUZIDAS
                        Text(
                          traduzida.instrucoesPt,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // 🔥 BOTÕES FLUTUANTES (UI NOVA)
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerTop,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // 🔙 VOLTAR
          FloatingActionButton(
            heroTag: "fab_1",
            mini: true,
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),

          // ❤️ FAVORITO
          FloatingActionButton(
            heroTag: "fab_2",
            mini: true,
            onPressed: () {
              if (estaFav) {
                favoritos.removerFavorito(original);
              } else {
                favoritos.adicionarFavorito(original);
              }
            },
            backgroundColor: Colors.white,
            child: Icon(
              estaFav
                  ? Icons.favorite
                  : Icons.favorite_outline,
              color: Colors.red,
            ),
          ),
        ],
      ),
    )
    );
  }
}