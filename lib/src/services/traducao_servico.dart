import 'package:translator/translator.dart';

class TraducaoServico {
  final GoogleTranslator _translator = GoogleTranslator();

  // ================================================================
  // PRÉ-PROCESSAMENTO (mantido do seu código)
  // ================================================================

  Map<int, String> _mapearLinhas(String texto) {
    final linhas = texto.split('\n');
    final mapa = <int, String>{};

    int index = 1;
    for (final l in linhas) {
      if (l.trim().isNotEmpty) {
        mapa[index] = l.trim();
        index++;
      }
    }

    return mapa;
  }

  String _limparLinha(String linha) {
    String t = linha;

    t = t.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), '');

    t = t.replaceAll(
      RegExp(
        r'\b\d+\s*(g|gr|grams|ml|kg|tablespoons|teaspoons|cups)\b',
        caseSensitive: false,
      ),
      '',
    );

    t = t.replaceAll(RegExp(r'\b\d+\b'), '');
    t = t.replaceAll(RegExp(r'\s{2,}'), ' ');

    return t.trim();
  }

  List<String> _prepararBlocos(Map<int, String> mapa) {
    List<String> blocos = [];

    for (final l in mapa.values) {
      final limpo = _limparLinha(l);
      if (limpo.isNotEmpty) {
        blocos.add(limpo);
      }
    }

    return blocos;
  }

  // ================================================================
  // 🔥 TRADUÇÃO COM TRANSLATOR (NOVA IMPLEMENTAÇÃO)
  // ================================================================

  Future<String> _traduzirBloco(String texto) async {
    try {
      final result = await _translator.translate(
        texto,
        from: 'en',
        to: 'pt',
      );

      final traduzido = result.text;

      if (traduzido.trim().isNotEmpty &&
          traduzido.trim().toLowerCase() != texto.trim().toLowerCase()) {
        return traduzido.trim();
      }

      return texto;
    } catch (e) {
      // fallback
      return texto;
    }
  }

  // ================================================================
  // RECONSTRUÇÃO (mantida)
  // ================================================================
  String _reconstruir(Map<int, String> original, List<String> traduzido) {
    List<String> linhasFinais = [];
    int index = 0;

    original.forEach((linha, conteudoOriginal) {
      if (index < traduzido.length) {
        linhasFinais.add(traduzido[index]); // ❌ remove numeração
        index++;
      }
    });

    return linhasFinais.join("\n\n");
  }

  // ================================================================
  // 🚀 MÉTODO PRINCIPAL
  // ================================================================

  Future<String> traduzirTexto(String texto) async {
    if (texto.trim().isEmpty) return texto;

    final mapaOriginal = _mapearLinhas(texto);
    final blocos = _prepararBlocos(mapaOriginal);

    final traduzidos = await Future.wait(
      blocos.map((b) => _traduzirBloco(b)),
    );

    return _reconstruir(mapaOriginal, traduzidos);
  }

  Future<String> traduzirSimples(String texto) async {
  try {
    final result = await _translator.translate(
      texto,
      from: 'en',
      to: 'pt',
    );
    return result.text;
  } catch (_) {
    return texto;
  }
}
}
