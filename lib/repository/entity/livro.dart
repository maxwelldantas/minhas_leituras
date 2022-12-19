class Livro {
  late int _id;
  late String _isbn;
  late String _autor;
  late String _titulo;
  late int _ano;
  late String _editora;
  late int _qtdPagina;
  late int _paginaLeitura;
  late bool _lido;
  late int _qtdLido;
  var _criadoEm;
  var _atualizadoEm;

  Livro.padrao();

  Livro(this._isbn, this._autor, this._titulo, this._ano, this._editora,
      this._qtdPagina, this._paginaLeitura, this._lido, this._qtdLido);

  get atualizadoEm => _atualizadoEm;

  set atualizadoEm(value) {
    _atualizadoEm = value;
  }

  get criadoEm => _criadoEm;

  set criadoEm(value) {
    _criadoEm = value;
  }

  int get qtdLido => _qtdLido;

  set qtdLido(int value) {
    _qtdLido = value;
  }

  bool get lido => _lido;

  set lido(bool value) {
    _lido = value;
  }

  int get paginaLeitura => _paginaLeitura;

  set paginaLeitura(int value) {
    _paginaLeitura = value;
  }

  int get qtdPagina => _qtdPagina;

  set qtdPagina(int value) {
    _qtdPagina = value;
  }

  String get editora => _editora;

  set editora(String value) {
    _editora = value;
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
