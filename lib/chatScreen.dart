import 'package:chatmathkekaflutterfirebase/chatMessage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'chatComposer.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //para o linearProgress indicator enquanto carrega envia imagem
  bool _carrengando = false;

  //----------------------------------------- Autenticação-com-Google -----------------------------------------------------
  //verifica se usuario ja está logado
  FirebaseUser _usuarioAtual;

  //antes de tudo tenta autenticar o usuario atual se estiver logado
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _usuarioAtual = user;
      });
    });
  }

  //cria snackbar para alertar possivel erro de login
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //pega a conta google a tentar logar
  final GoogleSignIn loginGoogle = GoogleSignIn();

  Future<FirebaseUser> _getUser() async {
    //verifica se já está logado
    if (_usuarioAtual != null) return _usuarioAtual;

    //não estando logado tenta logar
    try {
      //Faz login com conta google
      final GoogleSignInAccount contaLoginUsuario = await loginGoogle.signIn();

      //é necessário fazer login no Firebase tambem, sendo assim:
      final GoogleSignInAuthentication loginFirebaseComGoogleAutenticado =
          await contaLoginUsuario.authentication;
      /*pega os dados de autenticação da conta google autenticada e atribui o objeto do tipo googleSing... 
       O GoogleSignInAuthentication possui um idToken e um token de acesso para validar o login no FireBase ou outro*/

      //validação no firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: loginFirebaseComGoogleAutenticado.idToken,
          accessToken: loginFirebaseComGoogleAutenticado.accessToken);

      //login no Firebase
      final AuthResult resultAutenticFirebase =
          await FirebaseAuth.instance.signInWithCredential(credential);

      //feito login pega usuario do firebase
      final FirebaseUser userFirebase = resultAutenticFirebase.user;

      //retorna o usuario google validado e logado no Firebase
      return userFirebase;
    } catch (error) {
      return null;
    }
    // PS: a tentativa de login e feita ao tentar enviar a primeira msg, portanto, processo de usuario continua em _salvaMensagem()
  }

  //----------------------------------------------- salvar-mensagem -------------------------------------------------------
  void _salvaMensagem({String text, File imgFile}) async {
    //pega usuario firebase
    final FirebaseUser usuario = await _getUser();

    //valida usuario
    if (usuario == null) {
      //mostra uma mensagem de erro e pede pra tentar logar novamente
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível realizar login, tente novamente!"),
          backgroundColor: Colors.purple[800],
        ),
      );
    }

    //dados a enviar para o firebase
    Map<String, dynamic> dados = {
      "uid": usuario.uid,
      "senderName": usuario.displayName,
      "senderPhotoUrl": usuario.photoUrl,
      "time": Timestamp.now()
    };

    //salvar imagem se houver
    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(
            //nome do arquivo. para evitar conflitos, o nome é o uid do usuario concatenado com momento em milisegundos do mundo
            usuario.uid + DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .putFile(imgFile);

      //começa animação do linearProgressIndicator
      setState(() {
        _carrengando = true;
      });

      //recebe os dados da imagem que salvou
      StorageTaskSnapshot taskSnapshot = await task.onComplete;

      //pega a url do arquivo que salvou
      String url = await taskSnapshot.ref.getDownloadURL();
      dados['imgUrl'] = url;

      //enviou a imagem
      setState(() {
        _carrengando = false;
      });
    }

    if (text != null) {
      dados['text'] = text;
    }

    //adiciona tudo ao firebase
    Firestore.instance.collection('mensagens').add(dados);
  }

  // ------------------------------------------ front-end--do--app ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //snackbar para erro de login
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          title: Text(
            "Chat Particular Maléxia",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          // botão de deslogar do chat
          actions: <Widget>[
            _usuarioAtual != null
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      //desloga do firebase
                      FirebaseAuth.instance.signOut();

                      //desloga do google
                      loginGoogle.signOut();

                      //appBar avisando que deslogou
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text("Você deslogou com sucesso!"),
                        ),
                      );
                    })
                : Container(),
          ],
        ),
        body: Column(
          children: <Widget>[
            //lista que ocupa maior parte da tela com as mensagens
            Expanded(
              //streamBuilder para atualizar a lista a cada nova mensagem
              child: StreamBuilder<QuerySnapshot>(
                  //o stream pega a alteração no db
                  stream:
                      //order by para ordenar pela data de criação no firebase
                      Firestore.instance
                          .collection("mensagens")
                          .orderBy("time")
                          .snapshots(),
                  builder: (context, snapshot) {
                    //constroi a lista propriamente
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        //quando tiver os dados salva na lista
                        List<DocumentSnapshot> documentos =
                            snapshot.data.documents.reversed.toList();
                        //dados prontos, na list, constroi a lista de exibição
                        return ListView.builder(
                          itemCount: documentos.length,
                          reverse: true, //começa a lista de baixo para cima
                          itemBuilder: (context, index) {
                            return ChatMessage(
                                documentos[index].data,
                                documentos[index].data["uid"] ==
                                    _usuarioAtual?.uid);
                            // essa interrogação |  retorna nulo para o caso de não ter carregado um uid ainda,
                          },
                        );
                    }
                  }),
            ),
            //carregando imagem
            _carrengando
                ? LinearProgressIndicator(
                    backgroundColor: Colors.purple[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 250, 250, 255)),
                  )
                : Container(),
            //barra inferior (foto, textfield e enviar mensagem)
            ChatComposer(
                //salva mensagem no Firebase
                _salvaMensagem),
          ],
        ));
  }
}
