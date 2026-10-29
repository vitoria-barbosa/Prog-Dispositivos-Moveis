import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/contato.dart';

class BancoDeDados {
  BancoDeDados._();

  static final BancoDeDados instance = BancoDeDados._();

  late final Future<Database> _database = _abrirBanco();

  Future<Database> get database => _database;

  Future<Database> _abrirBanco() async {
    final String caminho;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      caminho = 'contatos.db';
    } else {
      caminho = join(await getDatabasesPath(), 'contatos.db');
    }

    return openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contatos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> criarContato(Contato contato) async {
    final db = await database;
    return db.insert('contatos', contato.toMap());
  }

  Future<int> editarContato(Contato contato) async {
    final id = contato.id;
    if (id == null) {
      throw ArgumentError('O contato precisa ter um id para ser editado.');
    }

    final db = await database;
    return db.update(
      'contatos',
      contato.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Contato>> selecionarContatos() async {
    final db = await database;
    final registros = await db.query(
      'contatos',
      orderBy: 'nome COLLATE NOCASE',
    );
    return registros.map(Contato.fromMap).toList();
  }

  Future<Contato?> selecionarContato(int id) async {
    final db = await database;
    final registros = await db.query(
      'contatos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (registros.isEmpty) {
      return null;
    }
    return Contato.fromMap(registros.first);
  }

  Future<int> apagarContato(int id) async {
    final db = await database;
    return db.delete('contatos', where: 'id = ?', whereArgs: [id]);
  }
}
