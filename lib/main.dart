import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Controllers
import 'src/controllers/receitas_controlador.dart';
import 'src/controllers/favoritos_controlador.dart';

// Pages
import 'src/pages/splash_screen.dart';

// SQLite FFI (Windows)
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const FlashReceitas());
}

class FlashReceitas extends StatelessWidget {
  const FlashReceitas({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReceitasControlador()..carregarReceitas(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritosControlador(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flash Receitas',

        // 🎨 TEMA GLOBAL
        theme: ThemeData(
          useMaterial3: true,

          scaffoldBackgroundColor: const Color(0xFFFFF5EC),

          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE65100),
            brightness: Brightness.light,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFF5EC),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFFE65100),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Color(0xFFE65100)),
          ),

          cardTheme: const CardThemeData(
            color: Colors.white,
            margin: EdgeInsets.all(12),
            shadowColor: Colors.black26,
            surfaceTintColor: Colors.transparent,
          ),
        ),

        // 🚀 Splash como entrada do app
        home: const SplashScreen(),
      ),
    );
  }
}