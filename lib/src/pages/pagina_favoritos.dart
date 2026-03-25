import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favoritos_controlador.dart';
import '../controllers/receitas_controlador.dart';
import '../models/receita.dart';
import 'pagina_detalhes_receita.dart';

class PaginaFavoritos extends StatelessWidget {
  const PaginaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritosControlador>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EC),

      appBar: AppBar(
        title: const Text("Favoritos"),
      ),

      body: favs.favoritos.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma receita favoritada 😕",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favs.favoritos.length,
              itemBuilder: (_, i) {
                return _CardFavorito(receita: favs.favoritos[i]);
              },
            ),
    );
  }
}

class _CardFavorito extends StatelessWidget {
  final Receita receita;

  const _CardFavorito({required this.receita});

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosControlador>();
    final controlador = context.watch<ReceitasControlador>();

    // 🔥 TRADUÇÃO DO CACHE
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 IMAGEM
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                receita.miniatura,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ✅ NOME TRADUZIDO
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ✅ CATEGORIA TRADUZIDA
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0B2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoria,
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🗑 REMOVER
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 28,
                      ),
                      onPressed: () =>
                          favoritos.removerFavorito(receita),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}