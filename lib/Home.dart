import 'package:anotacoessqflite/helper/AnotacaoHelper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'model/Anotacao.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTelaCadastro() {
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text("Aidiconar anotação"),
              content: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  TextField(
                    controller: _tituloController,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: "Título", hintText: "Digite o título..."),
                  ),
                  TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                        labelText: "Descrição",
                        hintText: "Digite a descrição..."),
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                FlatButton(
                  onPressed: _salvarAnotacao,
                  child: Text("Adicionar"),
                )
              ],
            ),
          );
        });
  }

  _recuperarAnotacao() async {
    List lista = await _db.recuperarAnotacoes();
    List<Anotacao> listaTemp = List<Anotacao>();

    for(var item in lista){
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemp.add(anotacao);
    }
    //print(listaTemp[1]);
    setState(() {
      _anotacoes = listaTemp;
    });
    listaTemp = null;
  }

  _salvarAnotacao() async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    //print("data atual " + DateTime.now().toString());
    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    int idInserido = await _db.salvarAnotacao(anotacao);
    Navigator.pop(context);
    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacao();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacao();
  }
  @override
  Widget build(BuildContext context) {
    _recuperarAnotacao();
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
                itemBuilder: (context, index){
                final anotacao = _anotacoes[index];

                  return Card(
                    child: ListTile(
                      title: Text(anotacao.titulo),
                      subtitle: Text(anotacao.data + " - " + anotacao.descricao),
                    ),
                  );
                })
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: _exibirTelaCadastro,
      ),
    );
  }
}
