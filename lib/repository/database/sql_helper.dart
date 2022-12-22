import 'package:flutter/foundation.dart';
import 'package:minhas_leituras/repository/entity/livro.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static const _databaseName = "MinhasLeiturasDB.db";
  static const _databaseVersion = 3;

  static const table = 'livros';

  static Future<void> createTables(sql.Database database) async {
    await database.execute('''
    CREATE TABLE $table
    (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        isbn TEXT,
        autor TEXT,
        titulo TEXT,
        ano INTEGER,
        editora TEXT,
        qtdPagina INTEGER,
        paginaLeitura INTEGER,
        lido TEXT CHECK ("lido" IN ("true","false")),
        qtdLido INTEGER,
        criadoEm TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        atualizadoEm TIMESTAMP
    )
    ''');
  }

// id: the id of a livro.
// autor, titulo, ano, paginas: attributes for livro.
// criado_em: the time that the livro was created. It will be automatically handled by SQLite.
// atualizado_em: the time that the livro was updated.

  static Future<sql.Database> db() async {
    // await rootBundle.load(join('assets', 'database.db'));
    return sql.openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new livro
  static Future<int> createLivro(
      String isbn,
      String autor,
      String titulo,
      int ano,
      String editora,
      int qtdPagina,
      int paginaLeitura,
      bool lido,
      int qtdLido) async {
    final db = await SQLHelper.db();

    Livro criarLivro = Livro(isbn, autor, titulo, ano, editora, qtdPagina,
        paginaLeitura, lido, qtdLido);

    String lidoText = lido.toString();

    final data = {
      'isbn': criarLivro.isbn,
      'autor': criarLivro.autor,
      'titulo': criarLivro.titulo,
      'ano': criarLivro.ano,
      'editora': criarLivro.editora,
      'qtdPagina': criarLivro.qtdPagina,
      'paginaLeitura': criarLivro.paginaLeitura,
      'lido': lidoText,
      'qtdLido': criarLivro.qtdLido
    };
    final id = await db.insert('livros', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all livros
  static Future<List<Map<String, dynamic>>> getLivros(String? telas) async {
    final db = await SQLHelper.db();
    String filtro;
    if ('paraLer'.contains(telas!)) {
      filtro = 'false';
      return db.query('livros', where: "lido = ?", whereArgs: [filtro]);
    } else if ('lidos'.contains(telas)) {
      filtro = 'true';
      return db.query('livros', where: "lido = ?", whereArgs: [filtro]);
    } else if ('favoritos'.contains(telas)) {
      filtro = 'true';
      return db.query('livros', where: "favorito = ?", whereArgs: [filtro]);
    }
    return db.query(null);
    // return db.query('livros', orderBy: "atualizadoEm");
  }

  // Read a single livro by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getLivro(int id) async {
    final db = await SQLHelper.db();
    return db.query('livros', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an livro by id
  static Future<int> updateLivro(
      int id,
      String isbn,
      String autor,
      String titulo,
      int ano,
      String editora,
      int qtdPagina,
      int paginaLeitura,
      bool lido,
      int qtdLido) async {
    final db = await SQLHelper.db();

    Livro atualizarLivro = Livro(isbn, autor, titulo, ano, editora, qtdPagina,
        paginaLeitura, lido, qtdLido);

    String lidoText = lido.toString();

    final data = {
      'isbn': atualizarLivro.isbn,
      'autor': atualizarLivro.autor,
      'titulo': atualizarLivro.titulo,
      'ano': atualizarLivro.ano,
      'editora': atualizarLivro.editora,
      'qtdPagina': atualizarLivro.qtdPagina,
      'paginaLeitura': atualizarLivro.paginaLeitura,
      'lido': lidoText,
      'qtdLido': atualizarLivro.qtdLido,
      'atualizadoEm': DateTime.now().toString()
    };

    final result =
        await db.update('livros', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteLivro(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("livros", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Algo deu errado ao excluir um livro: $err");
    }
  }
}
