import 'package:flutter/material.dart';

import 'pagina_inicio.dart';
import 'pagina_categorias.dart';
import 'pagina_favoritos.dart';

class PaginaBase extends StatefulWidget {
  const PaginaBase({super.key});

  @override
  State<PaginaBase> createState() => _PaginaBaseState();
}

class _PaginaBaseState extends State<PaginaBase> {
  int indice = 0;

  final List<Widget> paginas = const [
    PaginaInicio(),
    PaginaCategorias(),
    PaginaFavoritos(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: paginas[indice],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE65100).withOpacity(0.15),
        selectedIndex: indice,
        onDestinationSelected: (i) {
          setState(() {
            indice = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Início",
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: "Categorias",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: Colors.red),
            label: "Favoritos",
          ),
        ],
      ),
    );
  }
}