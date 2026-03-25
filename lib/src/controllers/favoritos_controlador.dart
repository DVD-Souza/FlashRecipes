import 'package:flutter/material.dart';
import '../models/receita.dart';

class FavoritosControlador extends ChangeNotifier {
  final List<Receita> _favoritos = [];

  List<Receita> get favoritos => List.unmodifiable(_favoritos);

  void adicionarFavorito(Receita receita) {
    if (!_favoritos.contains(receita)) {
      _favoritos.add(receita);
      notifyListeners();
    }
  }

  void removerFavorito(Receita receita) {
    _favoritos.remove(receita);
    notifyListeners();
  }

  bool estaFavorito(Receita receita) {
    return _favoritos.contains(receita);
  }
}