import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuapp2/controller/drawner_controller.dart';
import 'package:meuapp2/controller/firestore_controller.dart';
import '../controller/login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'controller/util.dart';
import 'lista_modificar.dart';

// PROJETO PARA CONFERIR VARIOS CAMINHOES DE UMA SO VEZ
final IdentificacaoController = LoginController();

class SelecionarDTScreen extends StatefulWidget {
  const SelecionarDTScreen({Key? key}) : super(key: key);

  @override
  State<SelecionarDTScreen> createState() => _SelecionarDTScreenState();
}

class _SelecionarDTScreenState extends State<SelecionarDTScreen> {
  final firestoreController = FirestoreController();

  final notafiscalController = TextEditingController();

  List<String> motoristas = [];

  String cliente = '';
  String quantidade = '';
  String codproduto = '';
  String data = '';
  String horario = '';
  String tipo = 'CAIXA';
  String motivo = 'AVARIA';

  String produto = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Clientes?;

    if (args != null) {
      setState(() {
        cliente = args.cliente;
        notafiscalController.text = args.notafiscal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        erro(context, 'Usuário não está autenticado!');
      }
    });

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            CustomDrawerHeader.getHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: const Text('Inicio'),
                      subtitle: const Text('NotaFiscal e Cliente'),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/selecionar');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logoff'),
                      subtitle: const Text('Finalizar a sessão'),
                      onTap: () {
                        LoginController().logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Controle de Ocorrência(s)'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<String>>(
              future: getMotoristas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  motoristas = snapshot.data!; // Atualiza a lista de motoristas

                  return FutureBuilder<List<String>>(
                    future: getDts(), // Obtém a lista de DTs
                    builder: (context, dtsSnapshot) {
                      if (dtsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (dtsSnapshot.hasData) {
                        List<String> dts = dtsSnapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: motoristas.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.delete),
                                title: Text(motoristas[index]),
                                onTap: () {
                                  _removerMotorista(index);
                                },
                                trailing: FloatingActionButton(
                                  onPressed: () {
                                    notafiscalController.text =
                                        motoristas[index];

                                    cliente =
                                        dts[index]; // Defina a DT do motorista
                                    // Ação adicional ao pressionar o botão "+" dentro do Card
                                  },
                                  mini: true,
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (dtsSnapshot.hasError) {
                        return const Text('Erro ao carregar DTs');
                      } else {
                        return const Text('Carregando DTs...');
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text('Erro ao carregar motoristas');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // Define a altura do contêiner igual à altura da tela
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('lib/images/background(3).jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 270.0),
                    Card(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/lista_nfs');
                        },
                        child: AbsorbPointer(
                          absorbing: true,
                          child: TextField(
                            onChanged: (text) {
                              notafiscalController.text = text;
                            },
                            controller: notafiscalController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Número da Nota Fiscal',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.list),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      color: Colors.grey[400],
                      child: TextFormField(
                        initialValue: cliente,
                        onChanged: (text) {
                          setState(() {
                            cliente = text;
                          });
                        },
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Codigo do Cliente',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields()) {
                          // SALVAR DADOS NO FIREBASE

                          firestoreController.salvarDadosAvariados(
                              cliente, notafiscalController.text);

                          Navigator.pushNamed(context, '/produtos');

                          //});
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (cliente.isEmpty ||
//        data.isEmpty ||
        notafiscalController.text.isEmpty) {
//        horario.isEmpty
      erro(context, 'Preencha todos os campos.');
      return false;
    } else {
      sucesso(context, 'Dados salvos com sucesso.');
      return true;
    }
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return formattedDate;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    return formattedTime;
  }

  void _removerMotorista(int index) async {
    if (index >= 0 && index < motoristas.length) {
      String motoristaRemover = motoristas[index];

      // Remover motorista do Firestore
      await FirebaseFirestore.instance
          .collection('ConferindoClientes')
          .where('notafiscal', isEqualTo: motoristaRemover)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          FirebaseFirestore.instance
              .collection('ConferindoClientes')
              .doc(docId)
              .delete();
        }
      });

      // Remover motorista da lista
      setState(() {
        motoristas.removeAt(index);
      });
    }
  }
}

Future<List<String>> getMotoristas() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('ConferindoClientes')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  final motoristas =
      snapshot.docs.map((doc) => doc['notafiscal'] as String).toList();
  return motoristas;
}

Future<List<String>> getDts() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('ConferindoClientes')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  final dts = snapshot.docs.map((doc) => doc['cliente'] as String).toList();
  return dts;
}
