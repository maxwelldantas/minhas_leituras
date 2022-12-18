class Livro {
  late int _id;
  late String _isbn;
  late String _autor;
  late String _titulo;
  late int _ano;
  late int _paginas;
  late int _paginaLeitura;
  var _criadoEm;
  var _atualizadoEm;

  Livro(this._isbn, this._autor, this._titulo, this._ano,
      this._paginas, this._paginaLeitura);

  get atualizadoEm => _atualizadoEm;

  set atualizadoEm(value) {
    _atualizadoEm = value;
  }

  get criadoEm => _criadoEm;

  set criadoEm(value) {
    _criadoEm = value;
  }

  int get paginaLeitura => _paginaLeitura;

  set paginaLeitura(int value) {
    _paginaLeitura = value;
  }

  int get paginas => _paginas;

  set paginas(int value) {
    _paginas = value;
  }

  int get ano => _ano;

  set ano(int value) {
    _ano = value;
  }

  String get titulo => _titulo;

  set titulo(String value) {
    _titulo = value;
  }

  String get autor => _autor;

  set autor(String value) {
    _autor = value;
  }

  String get isbn => _isbn;

  set isbn(String value) {
    _isbn = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}
