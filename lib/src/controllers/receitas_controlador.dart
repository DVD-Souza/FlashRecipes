import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../models/receita_traduzida.dart';
import '../services/api_receitas_servico.dart';
import '../services/traducao_servico.dart';
import '../services/banco_dados_servico.dart';

class ReceitasControlador extends ChangeNotifier {
  final ApiReceitasServico _api = ApiReceitasServico();
  final TraducaoServico _tradutor = TraducaoServico();
  final BancoDadosServico _banco = BancoDadosServico();
  final Map<String, ReceitaTraduzida> _cacheMemoria = {};

  List<Receita> _todasReceitas = [];
  List<Receita> _receitasFiltradas = [];

  bool carregando = false;

  List<Receita> get receitas => _receitasFiltradas;

  // Carrega lista de receitas da API
  Future<void> carregarReceitas() async {
    carregando = true;
    notifyListeners();

    _todasReceitas = await _api.buscarReceitas();
    _receitasFiltradas = [..._todasReceitas];

    carregando = false;
    notifyListeners();
  }

  // Busca local em memória
  void buscarReceitas(String termo) {
    if (termo.isEmpty) {
      _receitasFiltradas = [..._todasReceitas];
    } else {
      _receitasFiltradas = _todasReceitas
          .where((r) => r.nome.toLowerCase().contains(termo.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<ReceitaTraduzida> traduzirReceita(Receita receita) async {
    // 1. Cache em memória (ULTRA rápido)
    if (_cacheMemoria.containsKey(receita.id)) {
      return _cacheMemoria[receita.id]!;
    }

    // 2. Cache SQLite
    final existente = await _banco.buscarTraducao(receita.id);

    if (existente != null) {
      _cacheMemoria[receita.id] = existente;
      return existente;
    }

    // 3. Tradução
    final nomePt = await _tradutor.traduzirSimples(receita.nome);
    final categoriaPt = await _tradutor.traduzirSimples(receita.categoria);
    final instrucoesPt = await _tradutor.traduzirTexto(receita.instrucoes);

    final traducao = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: nomePt,
      categoriaPt: categoriaPt,
      instrucoesPt: instrucoesPt,
    );

    // salvar
    await _banco.salvarTraducao(traducao);
    _cacheMemoria[receita.id] = traducao;

    return traducao;
  }

  Future<void> _traduzirResumo(Receita receita) async {
    if (_cacheMemoria.containsKey(receita.id)) return;

    final existente = await _banco.buscarTraducao(receita.id);
    if (existente != null) {
      _cacheMemoria[receita.id] = existente;
      notifyListeners();
      return;
    }

    final nomePt = await _tradutor.traduzirSimples(receita.nome);
    final categoriaPt = await _tradutor.traduzirSimples(receita.categoria);

    final parcial = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: nomePt,
      categoriaPt: categoriaPt,
      instrucoesPt: "", // vazio por enquanto
    );

    _cacheMemoria[receita.id] = parcial;
    notifyListeners();
  }

  ReceitaTraduzida? getTraducao(String id) {
    return _cacheMemoria[id];
  }

  Future<void> traduzirResumoReceita(Receita receita) async {
    if (_cacheMemoria.containsKey(receita.id)) return;

    final nomePt = await _tradutor.traduzirSimples(receita.nome);
    final categoriaPt = await _tradutor.traduzirSimples(receita.categoria);

    final parcial = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: nomePt,
      categoriaPt: categoriaPt,
      instrucoesPt: "",
    );

    _cacheMemoria[receita.id] = parcial;
    notifyListeners();
  }
}
