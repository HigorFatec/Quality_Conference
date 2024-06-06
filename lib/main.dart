import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Importe o pacote Get

import 'package:firebase_core/firebase_core.dart';
import 'cadastrar.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'informacoes.dart';
import 'lista_modificar.dart';
import 'lista_produtos.dart';
import 'login_page.dart';
import 'produtos.dart';
import 'recuperar_senha.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Use GetMaterialApp em vez de MaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Camera Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/login',
      getPages: [
        // Defina suas rotas usando GetX
        GetPage(name: '/evidencia', page: () => Evidencia()),
        GetPage(name: '/selecionar', page: () => const SelecionarDTScreen()),
        GetPage(name: '/produtos', page: () => const AdicionarScreen()),
        GetPage(name: '/lista_nfs', page: () => const ClientesScreen2()),
        GetPage(name: '/lista_produtos', page: () => const ProdutosScreen2()),

        //TELA DE LOGIN
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/cadastrar', page: () => const CadastrarPage()),
        GetPage(
            name: '/recuperar_senha', page: () => const RecuperarSenhaPage()),
      ],
    );
  }
}
