import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/receitas_controlador.dart';
import '../controllers/favoritos_controlador.dart';
import '../models/receita.dart';
import 'pagina_detalhes_receita.dart';
import 'pagina_favoritos.dart';
import 'pagina_categorias.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<ReceitasControlador>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EC),

      appBar: AppBar(
        title: const Text("Receitas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaginaCategorias()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaginaFavoritos()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // 🔍 BARRA DE BUSCA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: controlador.buscarReceitas,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFFE65100)),
                  hintText: "Buscar receitas...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 📋 LISTA
          Expanded(
            child: controlador.carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controlador.receitas.length,
                    itemBuilder: (_, index) {
                      final receita = controlador.receitas[index];
                      return _CardReceita(receita: receita);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardReceita extends StatelessWidget {
  final Receita receita;

  const _CardReceita({required this.receita});

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosControlador>();
    final controlador = context.watch<ReceitasControlador>();

    final estaFav = favoritos.estaFavorito(receita);

    // 🔥 TRADUÇÃO
    final traduzida = controlador.getTraducao(receita.id);
    final nome = traduzida?.nomePt ?? receita.nome;
    final categoria = traduzida?.categoriaPt ?? receita.categoria;

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
        margin: const EdgeInsets.only(bottom: 18),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼 IMAGEM + FAVORITO
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Hero(
                    tag: receita.id,
                    child: Image.network(
                      receita.miniatura,
                      height: 210,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    right: 12,
                    top: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: Icon(
                          estaFav
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (estaFav) {
                            favoritos.removerFavorito(receita);
                          } else {
                            favoritos.adicionarFavorito(receita);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ✅ NOME TRADUZIDO
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ✅ CATEGORIA TRADUZIDA
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0B2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoria,
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}