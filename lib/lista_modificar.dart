import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'controller/login_controller.dart';

class Clientes {
  final String cliente;
  final String notafiscal;

  Clientes({
    required this.cliente,
    required this.notafiscal,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Clientes &&
        other.cliente == cliente &&
        other.notafiscal == notafiscal;
  }

  @override
  int get hashCode => cliente.hashCode ^ notafiscal.hashCode;
}

//PROJETO PARA CONFERIR VARIOS CAMINHAO
final IdentificacaoController = LoginController();

Future<bool> _verificarDtNoFirebase(String notafiscal) async {
  final query = await FirebaseFirestore.instance
      .collection('NFsFinalizadas')
      .where('notafiscal', isEqualTo: notafiscal)
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();

  //print('Verificando Firestore para DT: $dt, Existe: ${query.docs.isNotEmpty}');
  return query.docs.isNotEmpty;
}

Future<List<Clientes>?> fetchMotoristasFromFirestore() async {
  //
  //Obtendo a filial do usuario logado
  //

  LoginController loginController = LoginController();

  Map<String, dynamic> usuario = await loginController.usuarioLogado();
  String filial = usuario['filial'];

  // FIM

  // Obtenha uma referência para a coleção 'teste_json' no Firestore
  final collection = FirebaseFirestore.instance.collection('Clientes');

  // Obtenha os documentos da coleção 'teste_json'
  final snapshot = await collection.where('FILIAL', isEqualTo: filial).get();

  // Converta as linhas da planilha em objetos Motorista
  final motoristas2 = snapshot.docs.map((doc) {
    final data = doc.data();
    final cliente = data['CÓDIGO']?.toString().replaceAll('.0', '') ?? '';
    final notafiscal =
        data['NF']?.toString().replaceAll('000', '').replaceAll('-1', '') ?? '';

    return Clientes(
      cliente: cliente,
      notafiscal: notafiscal,
    );
  }).toList();
  return motoristas2.toSet().toList();
}

class ClientesScreen2 extends StatefulWidget {
  const ClientesScreen2({Key? key}) : super(key: key);

  @override
  _ClientesScreenState2 createState() => _ClientesScreenState2();
}

class _ClientesScreenState2 extends State<ClientesScreen2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de NFs'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('lib/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por NotaFiscal...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Clientes>?>(
                future: fetchMotoristasFromFirestore().catchError((error) {
                  print('Erro ao carregar DTS: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Clientes>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('Erro ao carregar DTS'));
                  } else {
                    final motoristas2 = snapshot.data!;

                    motoristas2
                        .sort((a, b) => a.notafiscal.compareTo(b.notafiscal));

                    return ListView.builder(
                      itemCount: motoristas2.length,
                      itemBuilder: (BuildContext context, int index) {
                        final motorista = motoristas2[index];
                        if (_searchText.isNotEmpty &&
                            !motorista.notafiscal
                                .toLowerCase()
                                .contains(_searchText.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<bool>(
                          future: _verificarDtNoFirebase(motorista.notafiscal),
                          builder: (context, snapshot) {
                            Color cardColor = Colors.white; // cor padrão

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == true) {
                                cardColor = Colors
                                    .green; // cor se dt estiver no Firebase
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/selecionar',
                                  arguments: motorista,
                                );
                              },
                              child: Card(
                                color: cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                          'NotaFiscal: ${motorista.notafiscal}'),
                                      subtitle:
                                          Text('Cliente: ${motorista.cliente}'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  return formattedDate;
}
