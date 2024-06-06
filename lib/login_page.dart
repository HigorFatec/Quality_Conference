import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var txtcpf = TextEditingController();
  var txtSenha = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _body() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150,
              ),
              SizedBox(
                width: 125,
                height: 125,
                child: ClipOval(
                  child: Image.asset('lib/images/logo.png'),
                ),
              ),
              Container(
                height: 15,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 20, bottom: 12),
                  child: Column(children: [
                    TextField(
                      controller: txtcpf,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 11,
                      decoration: const InputDecoration(
                          labelText: 'CPF',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: txtSenha,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String cpfComDominio = '${txtcpf.text}@cpf.com';

                            LoginController().login(
                              context,
                              cpfComDominio,
                              txtSenha.text,
                            );
                          },
                          child: const Text('Entrar'),
                        ),
                        const SizedBox(width: 145),
                        ElevatedButton(
                            child: const Text('Cadastrar'),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/cadastrar');
                            }),
                      ],
                    ),
                    GestureDetector(
                      onTap: _irParaRecuperarSenha,
                      child: const Column(
                        children: [
                          Text(
                            'Esqueceu a senha?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/selecionar');
        //sucesso(context, 'Usuário está autenticado!');
      }
    });
    return Scaffold(
        //  appBar: AppBar(
        //    title: const Text('Login'),
        //  ),
        body: Stack(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'lib/images/background(3).jpg',
              fit: BoxFit.cover,
            )),
        Container(
          color: Colors.black.withOpacity(0.2),
        ),
        _body(),
      ],
    ));
  }

  void _irParaRecuperarSenha() {
    Navigator.of(context).pushNamed('/recuperar_senha');
  }
}
