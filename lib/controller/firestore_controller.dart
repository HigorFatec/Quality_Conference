import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'login_controller.dart';

final IdentificacaoController = LoginController();

//codproduto, quantidade, tipo, notafiscal
class FirestoreController {
  Future<void> salvarDadosAvariados(String cliente, String notafiscal) async {
    try {
      //Obtendo nome do usuario logado
      Map<String, dynamic> usuario =
          await IdentificacaoController.usuarioLogado();
      String nome = usuario['nome'];
      String cargo = usuario['cargo'];
      String filial = usuario['filial'];
      // FIM

      // Obtenha uma referência para a coleção "motoristas"
      CollectionReference motoristasCollection =
          FirebaseFirestore.instance.collection('ConferindoClientes');

      // Crie um novo documento na coleção usando o método "add()"
      await motoristasCollection.add({
        'cliente': cliente,
        'notafiscal': notafiscal,
        'data': getCurrentDate(),
        'horario': getCurrentTime(),
        'filial': filial,
        'usuario': '$cargo $nome',
        'uid': IdentificacaoController.idUsuario(),
      });
    } catch (error) {}
  }

  //
  //Obtendo nome do usuario logado
  //

  Future<void> salvarEvidencias(String base64Image) async {
    //Obtendo nome do usuario logado
    Map<String, dynamic> usuario =
        await IdentificacaoController.usuarioLogado();
    String nome = usuario['nome'];
    String cargo = usuario['cargo'];
    String filial = usuario['filial'];
    // FIM

    QuerySnapshot NFsCollection = await FirebaseFirestore.instance
        .collection('ConferindoClientes')
        .where('uid', isEqualTo: IdentificacaoController.idUsuario())
        .get();
    QueryDocumentSnapshot firstDocument = NFsCollection.docs[0];
    String notafiscal = firstDocument.get('notafiscal');

    CollectionReference imagens =
        FirebaseFirestore.instance.collection('Evidencias');
    // Adicione um novo documento com a string base64 como campo
    await imagens.add({
      'imagem': base64Image,
      'notafiscal': notafiscal,
      'data': getCurrentDate(),
      'horario': getCurrentTime(),
      'filial': filial,
      'usuario': '$cargo $nome',
      'uid': IdentificacaoController.idUsuario(),
    });
  }

  Future<void> FinalizarConferencia() async {
    try {
      // Obter todos os dados das coleções adicionadas pelo usuários
      QuerySnapshot NFsCollection = await FirebaseFirestore.instance
          .collection('ConferindoClientes')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      QuerySnapshot ProdutosCollection = await FirebaseFirestore.instance
          .collection('ConferindoProdutos')
          .where('uid', isEqualTo: IdentificacaoController.idUsuario())
          .get();

      //Passando o estado de "Conferindo" para "Finalizado"
      for (QueryDocumentSnapshot documentSnapshot in NFsCollection.docs) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          await FirebaseFirestore.instance
              .collection('NFsFinalizadas')
              .add(data);
          await documentSnapshot.reference.delete();
        }
      }

      for (QueryDocumentSnapshot documentSnapshot in ProdutosCollection.docs) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ProdutosFinalizados')
              .add(data);
          await documentSnapshot.reference.delete();
        }
      }
    } catch (error) {}
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
