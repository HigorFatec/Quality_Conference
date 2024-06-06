import 'package:flutter/material.dart';
import 'package:meuapp2/controller/login_controller.dart';
import 'package:flutter/services.dart';

class CadastrarPage extends StatefulWidget {
  const CadastrarPage({Key? key}) : super(key: key);

  @override
  State<CadastrarPage> createState() => _CadastrarPageState();
}

class _CadastrarPageState extends State<CadastrarPage> {
  var txtnome = TextEditingController();
  var txtcpf = TextEditingController();
  var txtsenha = TextEditingController();
  var txtcargo = TextEditingController();
  var txtmatricula = TextEditingController();

  String email = '';
  String password = '';
  String cargo = '';
  String matricula = '';
  String admin = 'false';

  String txtfilial = 'Ribeirao Preto';

  @override
  void initState() {
    super.initState();
  }

  Widget _body() {
    return ListView(
      children: [
        Container(
          height: 100,
        ),
        Card(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 12),
            child: Column(
              children: [
                TextField(
                  controller: txtnome,
                  decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtcargo,
                  decoration: const InputDecoration(
                      labelText: 'Cargo',
                      prefixIcon: Icon(Icons.person_2),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtmatricula,
                  decoration: const InputDecoration(
                      labelText: 'Matricula',
                      prefixIcon: Icon(Icons.person_3),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: DropdownButtonFormField<String>(
                    value: txtfilial, // Valor selecionado
                    onChanged: (newValue) {
                      setState(() {
                        txtfilial = newValue!;
                      });
                    },
                    items: [
                      'Ribeirao Preto',
                      'Cacapava',
                      'Uberlandia',
                      'Santos'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Filial',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtcpf,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: 11,
                  decoration: const InputDecoration(
                      labelText: 'CPF',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: txtsenha,
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
                        // Adiciona o domínio "@cpf.com" ao e-mail fornecido pelo usuário
                        String cpfComDominio = '${txtcpf.text}@cpf.com';

                        LoginController().criarConta(
                          context,
                          txtnome.text,
                          cpfComDominio,
                          txtsenha.text,
                          txtcargo.text,
                          txtmatricula.text,
                          admin,
                          txtfilial,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Cadastrar'),
                    ),
                    const SizedBox(width: 140),
                    ElevatedButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar'),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'lib/images/background(3).jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          _body(),
        ],
      ),
    );
  }
}
