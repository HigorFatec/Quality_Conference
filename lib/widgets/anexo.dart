import 'dart:io';

import 'package:flutter/material.dart';

class Anexo extends StatelessWidget {
  final File arquivo;
  final Function(File) onDelete;

  Anexo({Key? key, required this.arquivo, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  arquivo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 75,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(255, 17, 0, 0.6),
              ),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                onPressed: () => onDelete(
                    arquivo), // Chama a função onDelete com o arquivo como parâmetro
              ),
            ),
          ),
        ],
      ),
    );
  }
}
