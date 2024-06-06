import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'controller/login_controller.dart';
import 'produtos.dart';

class Produtos {
  final String codigo;
  final String produto;
  final String notafiscal;

  Produtos({
    required this.codigo,
    required this.produto,
    required this.notafiscal,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Produtos &&
        other.codigo == codigo &&
        other.produto == produto;
  }

  @override
  int get hashCode => codigo.hashCode ^ produto.hashCode;
}

//PROJETO PARA CONFERIR VARIOS CAMINHAO
final IdentificacaoController = LoginController();

Future<bool> _verificarDtNoFirebase(String notafiscal, String codigo) async {
  // Verifica na primeira coleção
  final query1 = await FirebaseFirestore.instance
      .collection('ConferindoProdutos')
      .where('notafiscal', isEqualTo: notafiscal)
      .where('codigo', isEqualTo: codigo)
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();

  // Verifica na segunda coleção
  final query2 = await FirebaseFirestore.instance
      .collection('ProdutosFinalizados')
      .where('notafiscal', isEqualTo: notafiscal)
      .where('codigo', isEqualTo: codigo)
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();

  // Verifica se há documentos em pelo menos uma das coleções
  final bool existeEmPeloMenosUmaColecao =
      query1.docs.isNotEmpty || query2.docs.isNotEmpty;

  // Retorna verdadeiro se existir em pelo menos uma das coleções, falso caso contrário
  return existeEmPeloMenosUmaColecao;
}

Future<List<Produtos>?> fetchMotoristasFromFirestore() async {
  // Obtenha a lista de strings 'dts' usando a função 'getDts()'
  final nfs = await getNFs();

  // Converta a lista de strings para uma lista de inteiros
  //final nfsInt = dts.map(int.parse).toList();

  // Obtenha uma referência para a coleção 'teste_json' no Firestore
  final collection = FirebaseFirestore.instance.collection('Produtos');

  print(nfs.first);

  // Obtenha os documentos da coleção 'teste_json'
  final snapshot = await collection.where('NF', isEqualTo: nfs.first).get();

  // Converta as linhas da planilha em objetos Motorista
  final motoristas2 = snapshot.docs.map((doc) {
    final data = doc.data();
    final codigo = data['MATERIAL']?.toString() ?? '';
    final produto = data['DESCR. DO MATERIAL']?.toString() ?? '';
    final notafiscal = data['NF']?.toString() ?? '';

    return Produtos(
      codigo: codigo,
      produto: produto,
      notafiscal: notafiscal,
    );
  }).toList();
  return motoristas2.toSet().toList();
}

class ProdutosScreen2 extends StatefulWidget {
  const ProdutosScreen2({Key? key}) : super(key: key);

  @override
  _ProdutosScreenState2 createState() => _ProdutosScreenState2();
}

class _ProdutosScreenState2 extends State<ProdutosScreen2> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
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
              child: FutureBuilder<List<Produtos>?>(
                future: fetchMotoristasFromFirestore().catchError((error) {
                  print('Erro ao carregar DTS: $error');
                  return null; // Return null to indicate error
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Produtos>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('Erro ao carregar DTS'));
                  } else {
                    final motoristas2 = snapshot.data!;

                    motoristas2.sort((a, b) => a.produto.compareTo(b.produto));

                    return ListView.builder(
                      itemCount: motoristas2.length,
                      itemBuilder: (BuildContext context, int index) {
                        final motorista = motoristas2[index];
                        if (_searchText.isNotEmpty &&
                            !motorista.produto
                                .toLowerCase()
                                .contains(_searchText.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<bool>(
                          future: _verificarDtNoFirebase(
                              motorista.notafiscal, motorista.codigo),
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
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => AdicionarScreen(
                                      devolucaoSelecionada: motorista,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: cardColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title:
                                          Text('Produto: ${motorista.produto}'),
                                      subtitle: Text(
                                          'Codigo: ${motorista.codigo},\n NotaFiscal: ${motorista.notafiscal}'),
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

Future<List<String>> getNFs() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('ConferindoClientes')
      .where('uid', isEqualTo: IdentificacaoController.idUsuario())
      .get();
  final nfs = snapshot.docs
      .map((doc) => doc['notafiscal'] as String)
      .map((nf) => '000$nf-1')
      .toList();
  return nfs;
}
