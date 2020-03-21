import 'package:anotacoessqflite/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AnotacaoHelper {
  static final nomeTabela = "anotacao";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper.internal();
  Database _db;

  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }
  AnotacaoHelper.internal(){
  }

  _onCreate(Database db, int version) async{
    String sql = "CREATE TABLE $nomeTabela(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    await db.execute(sql);
  }

  get db async{
    if( _db != null){
      return _db;
    }
    else{
      _db = await _inicializarDB();
      return _db;
    }
  }

  _inicializarDB() async{
    final pathDB = await getDatabasesPath();
    final localDB = join(pathDB, "bd_anotacoes.db");

    var db = await openDatabase(localDB, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async{
    var banco = await db;
    return await banco.insert(nomeTabela, anotacao.toMap());
  }

  recuperarAnotacoes() async{
    var banco = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await banco.rawQuery (sql);
    return anotacoes;


  }
}