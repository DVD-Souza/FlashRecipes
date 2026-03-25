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
    final cache = _cacheMemoria[receita.id];

    if (cache != null && cache.instrucoesPt.isNotEmpty) {
      return cache;
    }

    final existente = await _banco.buscarTraducao(receita.id);

    if (existente != null && existente.instrucoesPt.isNotEmpty) {
      _cacheMemoria[receita.id] = existente;
      return existente;
    }

    if (existente != null && existente.instrucoesPt.isEmpty) {
      // 🔥 precisa atualizar tradução completa
      debugPrint("Atualizando tradução incompleta...");
    } 

    final nomePt = await _tradutor.traduzirSimples(receita.nome);
    final categoriaPt = await _tradutor.traduzirSimples(receita.categoria);
    final instrucoesPt = await _tradutor.traduzirTexto(receita.instrucoes);

    final traducao = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: nomePt,
      categoriaPt: categoriaPt,
      instrucoesPt: instrucoesPt,
    );

    await _banco.salvarTraducao(traducao);
    _cacheMemoria[receita.id] = traducao;

    return traducao;
  }

  Future<void> _traduzirResumo(Receita receita) async {
  final existente = await _banco.buscarTraducao(receita.id);

  if (existente != null) return;

  try {
    final nomePt = await _tradutor.traduzirSimples(receita.nome);
    final categoriaPt = await _tradutor.traduzirSimples(receita.categoria);

    final receitaTraduzida = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: nomePt,
      categoriaPt: categoriaPt, // ✅ agora traduzido
      instrucoesPt: "",
    );

   if (!_cacheMemoria.containsKey(receita.id)) {
      _cacheMemoria[receita.id] = receitaTraduzida;
    }

  } catch (e) {
    debugPrint("Erro ao traduzir: $e");
  }
  }

  ReceitaTraduzida? getTraducao(String id) {
    return _cacheMemoria[id];
  }

  final Set<String> _traduzindo = {};

  void traduzirSeNecessario(Receita receita) {
    if (_cacheMemoria.containsKey(receita.id)) return;
    if (_traduzindo.contains(receita.id)) return;

    _traduzindo.add(receita.id);

    _traduzirResumo(receita).then((_) async {
    try {
        final traduzida = await _banco.buscarTraducao(receita.id);

        if (traduzida != null && traduzida.instrucoesPt.isNotEmpty) {
          _cacheMemoria[receita.id] = traduzida;
        }

        _traduzindo.remove(receita.id);
        notifyListeners(); // 🔥 atualiza UI automaticamente
      } catch (_) {}

      _traduzindo.remove(receita.id);
      notifyListeners();
    });    
  }

  Future<Receita> buscarReceitaPorId(String id) async {
    return await _api.buscarReceitaPorId(id);
  }
}