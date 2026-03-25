import 'package:flutter/material.dart';
import 'dart:async';

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
  final Duration debounceDuration = const Duration(milliseconds: 500);
  Timer? _debounce;

  List<Receita> _todasReceitas = [];
  List<Receita> _receitasFiltradas = [];

  bool carregando = false;

  List<Receita> get receitas => _receitasFiltradas;

  // =========================
  // CARREGAR RECEITAS INICIAIS
  // =========================
  Future<void> carregarReceitas() async {
    carregando = true;
    notifyListeners();

    try {
      _todasReceitas = await _api.buscarReceitas();
      _receitasFiltradas = [..._todasReceitas];
    } catch (e) {
      debugPrint("Erro ao carregar receitas: $e");
      _todasReceitas = [];
      _receitasFiltradas = [];
    }

    carregando = false;
    notifyListeners();
  }

  // =========================
  // BUSCA LOCAL (PT + EN)
  // =========================
  void buscarReceitas(String termo) {
    if (termo.isEmpty) {
      _receitasFiltradas = [..._todasReceitas];
    } else {
      final t = termo.toLowerCase();
      _receitasFiltradas = _todasReceitas.where((r) {
        final traducao = _cacheMemoria[r.id];
        final nomePt = traducao?.nomePt ?? "";
        return r.nome.toLowerCase().contains(t) ||
            nomePt.toLowerCase().contains(t);
      }).toList();
    }

    notifyListeners();
  }

  // =========================
  // TRADUZIR RECEITAS
  // =========================
  Future<ReceitaTraduzida> traduzirReceita(Receita receita) async {
    final cache = _cacheMemoria[receita.id];
    if (cache != null && cache.instrucoesPt.isNotEmpty) return cache;

    final existente = await _banco.buscarTraducao(receita.id);
    if (existente != null && existente.instrucoesPt.isNotEmpty) {
      _cacheMemoria[receita.id] = existente;
      return existente;
    }

    // Traduzir campos
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

  ReceitaTraduzida? getTraducao(String id) => _cacheMemoria[id];

  final Set<String> _traduzindo = {};

  void traduzirSeNecessario(Receita receita) {
    if (_cacheMemoria.containsKey(receita.id)) return;
    if (_traduzindo.contains(receita.id)) return;

    _traduzindo.add(receita.id);

    _traduzirResumo(receita).then((_) async {
      final traduzida = await _banco.buscarTraducao(receita.id);
      if (traduzida != null && traduzida.instrucoesPt.isNotEmpty) {
        _cacheMemoria[receita.id] = traduzida;
      }
      _traduzindo.remove(receita.id);
      notifyListeners();
    });
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
        categoriaPt: categoriaPt,
        instrucoesPt: "",
      );

      _cacheMemoria[receita.id] = receitaTraduzida;
    } catch (e) {
      debugPrint("Erro ao traduzir resumo: $e");
    }
  }

  Future<Receita> buscarReceitaPorId(String id) async {
    return await _api.buscarReceitaPorId(id);
  }

  // =========================
  // BUSCA MULTILÍNGUE COM API
  // =========================
  Future<void> _buscarReceitasMultilanguage(String termo) async {
    carregando = true;
    notifyListeners();

    try {
      if (termo.isEmpty) {
        await carregarReceitas();
        return;
      }

      final t = termo.toLowerCase();

      // 1️⃣ Filtrar localmente pelo nome original ou traduzido
      _receitasFiltradas = _todasReceitas.where((r) {
        final traducao = _cacheMemoria[r.id];
        final nomePt = traducao?.nomePt ?? "";
        return r.nome.toLowerCase().contains(t) ||
            nomePt.toLowerCase().contains(t);
      }).toList();

      // 2️⃣ Traduzir o termo digitado para inglês
      String termoIngles;
      try {
        termoIngles =
            await _tradutor.traduzirSimples(termo, from: 'pt', to: 'en');
      } catch (_) {
        termoIngles = termo; // fallback
      }

      // 3️⃣ Consultar API usando termo em inglês
      final listaApi = await _api.buscarReceitasPorTermo(
        "https://www.themealdb.com/api/json/v1/1/search.php?s=$termoIngles"
      );

      // 4️⃣ Adicionar resultados que ainda não estão na lista
      for (final r in listaApi) {
        if (!_receitasFiltradas.any((x) => x.id == r.id)) {
          _receitasFiltradas.add(r);
        }
      }
    } catch (e) {
      debugPrint("Erro na busca multilíngue: $e");
      _receitasFiltradas = [];
    }

    carregando = false;
    notifyListeners();
  }

  // =========================
  // DEBOUNCE PARA BUSCA
  // =========================
  void buscarReceitasComDebounce(String termo) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      _buscarReceitasMultilanguage(termo);
    });
  }

  Future<String> traduzirTextoSimples(String texto, {String from = 'en', String to = 'pt'}) async {
    return await _tradutor.traduzirSimples(texto, from: from, to: to);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}