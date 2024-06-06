import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'controller/drawner_controller.dart';
import 'controller/firestore_controller.dart';
import 'controller/login_controller.dart';
import 'controller/util.dart';
import 'preview_page.dart';
import 'widgets/anexo.dart';

//PROJETO PARA CONFERIR VARIOS CAMINHAO
final IdentificacaoController = LoginController();

final FinalizacaoConferencia = FirestoreController();

class Evidencia extends StatefulWidget {
  Evidencia({Key? key}) : super(key: key);

  @override
  _EvidenciaState createState() => _EvidenciaState();
}

class _EvidenciaState extends State<Evidencia> {
  List<File> arquivos = [];
  final picker = ImagePicker();

  Future<void> showPreview(File file) async {
    File? arq = await Get.to(() => PreviewPage(file: file));

    if (arq != null) {
      setState(() => arquivos.add(arq)); // Adicione o arquivo à lista
    }
  }

  Future<void> enviarParaFirestore(File file) async {
    try {
      // Converta o arquivo para base64
      String base64Image = await convertImageToBase64(file);
      base64Image = 'data:image/jpeg;base64,$base64Image';

      //Obtendo Nota Fiscal para atribuir ao Produto

      FinalizacaoConferencia.salvarEvidencias(
          base64Image); // Salve a imagem no Firestore

      print('Imagem enviada com sucesso para o Firestore');
    } catch (e) {
      print('Erro ao enviar imagem para o Firestore: $e');
    }
  }

  Future<String> convertImageToBase64(File file) async {
    try {
      List<int> imageBytes = file.readAsBytesSync();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Erro ao converter imagem para base64: $e');
      return '';
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
        title: const Text('Evidência de Ocorrência(s)'),
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => CameraCamera(onFile: (file) => showPreview(file)),
            ),
            icon: const Icon(Icons.camera_alt),
          ),
        ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: arquivos.length,
                itemBuilder: (BuildContext context, int index) {
                  return Anexo(
                      arquivo: arquivos[index],
                      onDelete: (file) {
                        setState(() => arquivos.remove(file));
                      });
                },
              ),
            ),
            Card(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (arquivos.isEmpty) {
                    erro(context, 'Nenhuma imagem adicionada');
                  } else {
                    for (var file in arquivos) {
                      await enviarParaFirestore(file);
                    }
                    setState(() =>
                        arquivos.clear()); // Limpe a lista depois de enviar
                    try {
                      await FinalizacaoConferencia.FinalizarConferencia();
                      Navigator.of(context).pushReplacementNamed('/selecionar');
                      sucesso(context, 'Conferência finalizada com sucesso!');
                    } catch (e) {
                      erro(context, 'Erro ao finalizar conferencia: $e');
                    }
                  }
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Enviar dados'),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
