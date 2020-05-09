import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  //construtor da classe
  ChatMessage(this.dados, this.minhaMensagem);
  //dados das mensagens vindos da chatScreen
  final Map<String, dynamic> dados;
  final bool minhaMensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        children: <Widget>[
          //imagem da pessoa que mandou a msg
          !minhaMensagem
              ? Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      dados['senderPhotoUrl'],
                      //mensagem ocupando a maior parte da row
                    ),
                  ),
                )
              : Container(),
          Expanded(
            //coluna para colocar embaixo da msg quem enviou
            child: Column(
              crossAxisAlignment: minhaMensagem
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                //mensagem
                dados['imgUrl'] == null
                    ? Text(
                        dados['text'],
                        textAlign:
                            minhaMensagem ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Image.network(
                        dados['imgUrl'],
                        width: 250.0,
                      ),
                Text(
                  dados['senderName'],
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          minhaMensagem
              ? Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      dados['senderPhotoUrl'],
                      //mensagem ocupando a maior parte da row
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
