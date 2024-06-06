import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuapp2/controller/drawner_controller.dart';
import 'package:meuapp2/controller/util.dart';

import '../controller/login_controller.dart';
import 'lista_produtos.dart';

class AdicionarScreen extends StatefulWidget {
  final Produtos? devolucaoSelecionada;

  const AdicionarScreen({Key? key, this.devolucaoSelecionada})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdicionarScreenState createState() => _AdicionarScreenState();
}

class _AdicionarScreenState extends State<AdicionarScreen> {
  final List<Devolucao> _devolucoes = [];
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _notafiscalController = TextEditingController();

  String codproduto = '';
  String quantidade = '';
  String notafiscal = '';
  String tipo = 'CAIXA';
  String motivo = 'AVARIA';

  //PROJETO PARA CONFERIR VARIOS CAMINHAO
  final IdentificacaoController = LoginController();

  @override
  @override
  void initState() {
    super.initState();
    _carregarDevolucoes();
    if (widget.devolucaoSelecionada != null) {
      _nomeController.text = widget.devolucaoSelecionada!.produto;
      _codigoController.text = widget.devolucaoSelecionada!.codigo;
      _notafiscalController.text = widget.devolucaoSelecionada!.notafiscal;
    }
  }

  Future<void> _carregarDevolucoes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ConferindoProdutos')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();

    final devolucoes = snapshot.docs.map((doc) {
      final data = doc.data();
      return Devolucao(
        codigo: data['codigo'],
        nome: data['nome'],
        quantidade: data['quantidade'],
        tipo: data['tipo'],
        motivo: data['motivo'],
        notafiscal: data['notafiscal'],
        filial: data['filial'],
        uid: data['uid'],
        docId: doc.id, // Atribuir o ID do documento ao objeto Devolucao
      );
    }).toList();

    setState(() {
      _devolucoes.clear();
      _devolucoes.addAll(devolucoes);
    });
  }

  void _adicionarDevolucao() async {
    String filialUsuario = await IdentificacaoController.filial();

    final novaDevolucao = Devolucao(
      codigo: _codigoController.text,
      nome: _nomeController.text,
      quantidade: quantidade,
      tipo: tipo,
      motivo: motivo,
      notafiscal: _notafiscalController.text,
      filial: filialUsuario,
      uid: IdentificacaoController.idUsuario(),
      docId: '', // Será preenchido posteriormente com o ID do documento
    );

    final docRef = await FirebaseFirestore.instance
        .collection('ConferindoProdutos')
        .add(novaDevolucao.toMap());
    final docId = docRef.id;

    novaDevolucao.docId = docId;

    setState(() {
      _devolucoes.add(novaDevolucao); // Adiciona a devolução à lista
    });
  }

  void _removerDevolucao(int index) async {
    if (index >= 0 && index < _devolucoes.length) {
      final devolucao = _devolucoes[index];
      final docId = devolucao.docId;

      final docRef = FirebaseFirestore.instance
          .collection('ConferindoProdutos')
          .doc(docId);
      print('Documento ID: $docId');
      await docRef.delete();

      setState(() {
        _devolucoes.removeAt(index);
      });

      //PREENCHENDO OS CAMPOS COM O NOME E QUANTIDADE EXCLUIDOS
      //_nomeController.text = devolucao.nome;
      //_quantidadeController.text = devolucao.quantidade;
    }
  }

  void _salvarDevolucoes() async {
    // Busca as devoluções do usuário no Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('ConferindoProdutos')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();
    if (snapshot.docs.isNotEmpty) {
      // Se houver devoluções, avance para a próxima tela
      sucesso(context, 'Produtos salvos com Sucesso!');
      // Navegar para a proxima tela
      Navigator.of(context).pushReplacementNamed('/evidencia');
    } else {
      erro(context, 'Por favor, adicione pelo menos um produto.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        _nomeController.text = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Produtos'),
      ),
      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _devolucoes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        child: const Icon(Icons.delete, size: 40),
                        onTap: () {
                          _removerDevolucao(index);
                        },
                      ),
                      title: Text(_devolucoes[index].nome),
                      subtitle: Text(
                          '${_devolucoes[index].quantidade} ${_devolucoes[index].tipo}(s)'),
                      trailing: FloatingActionButton(
                        onPressed: () {
                          _nomeController.text = _devolucoes[index].nome;
                          // Ação adicional ao pressionar o botão "+" dentro do Card
                        },
                        mini: true,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Adicionar Produto(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Card(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/lista_produtos');
                            },
                            child: AbsorbPointer(
                              absorbing: true,
                              child: TextField(
                                onChanged: (text) {
                                  _nomeController.text = text;
                                },
                                controller: _nomeController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: 'Nome do Produto',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.list),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Card(
                          child: TextFormField(
                            initialValue: quantidade,
                            onChanged: (text) {
                              quantidade = text;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Quantidade',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.format_list_numbered),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          color: Colors.white,
                          child: DropdownButtonFormField<String>(
                            value: tipo, // Valor selecionado
                            onChanged: (newValue) {
                              setState(() {
                                tipo = newValue!;
                              });
                            },
                            items: ['UNIDADE', 'PACK', 'CAIXA']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Produto',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          color: Colors.white,
                          child: DropdownButtonFormField<String>(
                            value: motivo, // Valor selecionado
                            onChanged: (newValue) {
                              setState(() {
                                motivo = newValue!;
                              });
                            },
                            items: ['AVARIA', 'QUALIDADE', 'REPOSIÇÃO', 'SHELF']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: 'Motivo',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_validateFields() == true) {
                          sucesso(context, 'Produto inserido com sucesso!');
                          _adicionarDevolucao();
                        } else {
                          erro(context, 'Por favor, preencha todos os campos.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(220, 40),
                      ),
                      child: const Text('Adicionar Produto'),
                    ),
                    ElevatedButton(
                      onPressed: _salvarDevolucoes,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 40),
                      ),
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
    if (_nomeController.text.isEmpty || quantidade.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

class Devolucao {
  final String codigo;
  final String nome;
  final String quantidade;
  final String tipo;
  final String motivo;
  final String notafiscal;
  final String filial;
  final String uid;
  String? docId;

  Devolucao({
    required this.codigo,
    required this.nome,
    required this.quantidade,
    required this.tipo,
    required this.motivo,
    required this.notafiscal,
    required this.filial,
    required this.uid,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'quantidade': quantidade,
      'tipo': tipo,
      'motivo': motivo,
      'notafiscal': notafiscal,
      'filial': filial,
      'uid': uid,
    };
  }
}
