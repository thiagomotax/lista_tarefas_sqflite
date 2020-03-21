import 'package:anotacoessqflite/helper/AnotacaoHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'model/Anotacao.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();
  var titulo;
  var botao;

  _exibirTelaCadastro({Anotacao anotacao}) {
    if (anotacao == null) {
      //salvando
      _tituloController.text = "";
      _descricaoController.text = "";
      titulo = "Nova anotação";
      botao = "Adicionar";
    } else {
      //editando
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      titulo = "Editar anotação";
      botao = "Editar";
    }
    showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text(titulo),
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
                  onPressed: () async => _salvarAtualizarAnotacao(nota: anotacao),
                  child: Text(botao),
                )
              ],
            ),
          );
        });
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    var formatter = DateFormat.yMMMMd("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatter.format(dataConvertida);
    return dataFormatada;
  }

  _recuperarAnotacao() async {
    List lista = await _db.recuperarAnotacoes();
    List<Anotacao> listaTemp = List<Anotacao>();

    for (var item in lista) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemp.add(anotacao);
    }
    //print(listaTemp[1]);
    setState(() {
      _anotacoes = listaTemp;
    });
    listaTemp = null;
  }
  _excluirAnotacao(Anotacao anotacao) async {
    await _db.excluirAnotacao(anotacao);
  }
   _salvarAtualizarAnotacao({Anotacao nota}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    if (nota == null) {
      int resultado  = await _db.salvarAnotacao(anotacao);
      print("salvou " + resultado.toString());
      Navigator.pop(context);
      _tituloController.clear();
      _descricaoController.clear();

    } else //editar
    {
      nota.titulo = titulo;
      nota.descricao = descricao;
      int resultado = await _db.editarAnotacao(nota);
      print("editou " + resultado.toString());
      Navigator.pop(context);
      _tituloController.clear();
      _descricaoController.clear();
    }
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
                  itemBuilder: (context, index) {
                    final anotacao = _anotacoes[index];

                    return Card(
                      child: ListTile(
                        title: Text(anotacao.titulo),
                        subtitle: Text(_formatarData(anotacao.data) +
                            "  " +
                            anotacao.descricao),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _exibirTelaCadastro(anotacao: anotacao);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _excluirAnotacao(anotacao);
                              },
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }))
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
