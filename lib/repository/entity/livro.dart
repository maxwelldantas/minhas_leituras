class Livro {
  late int id;
  late String isbn;
  late String autor;
  late String titulo;
  late int ano;
  late String editora;
  late int qtdPagina;
  late int paginaLeitura;
  late bool lido;
  late int qtdLido;
  late bool favorito;
  dynamic criadoEm;
  dynamic atualizadoEm;

  Livro.padrao();

  Livro(
      this.isbn,
      this.autor,
      this.titulo,
      this.ano,
      this.editora,
      this.qtdPagina,
      this.paginaLeitura,
      this.lido,
      this.qtdLido,
      this.favorito);
}
