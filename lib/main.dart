import 'package:chatmathkekaflutterfirebase/chatScreen.dart';
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(MyApp(),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pinkAccent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      home: ChatScreen(),
    );
  }

  //conexão com o Firebase
  // Firestore.instance
  //     .collection("col")
  //     .document("doc")
  //     .setData({"texto": "Matheus"});
  //o Firestore usa o padrão singleton para apontar ao DB
  /*Padrão de acesso ao db:

  Escrita:

    #escrever (sobrescrevendo todos valores):

      Firestore.instance.collection("qual collection acessar ou criar (para criar um id unico, deixar vazio)")
      .document("qual document acessar ou criar").setData({"chave":"dado"});
      
    #escrever (sobrescrevendo, atualizando um valor específico): 

      Firestore.instance.collection("qual collection acessar ou criar (para criar um id unico, deixar vazio)")
      .document("qual document acessar ou criar")..updateData({"chave":"dado"});

    #escrever após pegar todos os documentos (inserir ou atualizar um campo):

      QuerySnapshot snapshot = await Firestore.instance.collection("qual coleção").getDocuments();
      snapshot.documets.forEach((dado){
        dado.reference.updateData({"chave":"dado"});
      });


  Leitura:
                                          **"Query" pega vários documentos e "Document" apenas um**
    #pegar todos os documentos e dados dos documentos (fotografia):

      QuerySnapshot snapshot = await Firestore.instance.collection("qual coleção").getDocuments();
      snapshot.documets.forEach((dado){
        print(dado.documentID); //mostra o id
        print(dado.data); //mostra os dados do documento na respectiva collection
      });

    #pegar os dados de um documento específico (fotografia)

      DocumentSnapshot snapshot = await Firestore.instance.collection("qual collection").document("id do documento").get();
      print(snapshot.data);

    ##-Leitura de coleções em tempo real-##

      Firestore.instance.collection("collection").snapshots().listen((dado){
        //a cada alteração ele pega todos os documentos de todas collections
        dado.documents.forEach((dado){
          print(dado.data);
        });
      });
    
    ##-Leitura de documentos específicos em tempo real-##

      Firestore.instance.collection("collection").document("id do documento").snapshots().listen((dado){
        //a cada atualização nesse documento em específico e apenas nele, pega novamente seus dados
        print(dado.data);
      })
   
   */
}
