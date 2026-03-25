import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/receita_traduzida.dart';

class BancoDadosServico {
  static Database? _db;

  Future<Database> get banco async {
    if (_db != null) return _db!;
    _db = await _iniciarBanco();
    return _db!;
  }

  Future<Database> _iniciarBanco() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Caminho base
      final pathBase = await databaseFactory.getDatabasesPath();

      // GARANTIR QUE A PASTA EXISTE
      final dir = Directory(pathBase);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Caminho completo do banco
      final path = join(pathBase, "receitas.db");

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute("""
              CREATE TABLE traducoes (
                idReceita TEXT PRIMARY KEY,
                nomePt TEXT,
                categoriaPt TEXT,
                instrucoesPt TEXT
              );
            """);
          },
        ),
      );
    }

    // ANDROID
    final path = join(await getDatabasesPath(), "receitas.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE traducoes (
            idReceita TEXT PRIMARY KEY,
            nomePt TEXT,
            categoriaPt TEXT,
            instrucoesPt TEXT
          );
        """);
      },
    );
  }

  Future<void> salvarTraducao(ReceitaTraduzida traducao) async {
    final db = await banco;
    await db.insert(
      "traducoes",
      traducao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ReceitaTraduzida?> buscarTraducao(String id) async {
    final db = await banco;

    final resultado = await db.query(
      "traducoes",
      where: "idReceita = ?",
      whereArgs: [id],
    );

    if (resultado.isNotEmpty) {
      return ReceitaTraduzida.fromMap(resultado.first);
    }

    return null;
  }
}