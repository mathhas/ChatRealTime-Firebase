import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatComposer extends StatefulWidget {
  //retorna a mensagem digitada pelos parametros da propria função
  ChatComposer(this.sendMessage);
  final Function({String text, File imgFile})
      sendMessage; //final apenas para tirar o erro e @immutable pois e stful

  @override
  _ChatComposerState createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  //par ativar ou desativar o botão de enviar
  bool _digitando = false;
  //controlador para submeter a mensagem pelo botão de enviar (controller pega o texto e salva numa variavel)
  final TextEditingController _sendController = TextEditingController();

  //desativar botão de enviar
  void _desativarBotaoEnviar() {
    setState(() {
      _digitando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //barrinha com icone de anexar foto, digitar texto e enviar
      child: Row(
        children: <Widget>[
          //anexar foto
          IconButton(
              icon: Icon(Icons.photo_camera),
              //como envolve tempo de espera, tornar async
              onPressed: () async {
                //abrir camera
                File imgFile =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                //verificar se tirou foto ou nao para enviar
                if (imgFile == null) return;
                widget.sendMessage(imgFile: imgFile);
              }),
          //campo de texto ocupando a maior parte do chatComposer
          Expanded(
            child: TextField(
              controller: _sendController,
              //deixar o mais próximo do inferior possivel
              decoration: InputDecoration.collapsed(
                  hintText: "Insira a mensagem aqui..."),
              onChanged: (text) {
                //anima o botão de enviar
                setState(() {
                  //se o campo nao for vazio está digitando
                  _digitando = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                //envia a mensagem para a função no parametro da chatComposer, na chatScreen
                widget.sendMessage(text: text);
                //depois de enviar, limpar o textField
                _sendController.clear();

                _desativarBotaoEnviar();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _digitando
                  ? () {
                      //se tiver texto ativa o botão e ao pressionar envia mensagem no chat
                      widget.sendMessage(text: _sendController.text);
                      //depois de enviar, limpar o textField
                      _sendController.clear();

                      _desativarBotaoEnviar();
                    }
                  : null //senão desativa o botão,
              )
        ],
      ),
    );
  }
}
