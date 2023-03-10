import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minhas_leituras/repository/database/sql_helper.dart';
import 'package:minhas_leituras/widget/stateful/favoritos_widget.dart';

class FavoritosTela extends State<FavoritosWidget> {
  // All livros
  List<Map<String, dynamic>> _livros = [];

  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshLivros() async {
    final data = await SQLHelper.getLivros('favoritos');
    setState(() {
      _livros = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshLivros(); // Loading the diary when the app starts
  }

  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _editoraController = TextEditingController();
  final TextEditingController _qtdPaginaController = TextEditingController();
  final TextEditingController _paginaLeituraController =
      TextEditingController();
  bool? _lidoController = false;
  final TextEditingController _qtdLidoController = TextEditingController();
  bool? _favoritoController = false;

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an livro
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new livro
      // id != null -> update an existing livro
      final existingLivros =
          _livros.firstWhere((element) => element['id'] == id);
      _isbnController.text = existingLivros['isbn'];
      _autorController.text = existingLivros['autor'];
      _tituloController.text = existingLivros['titulo'];
      _anoController.text = existingLivros['ano'].toString();
      _qtdPaginaController.text = existingLivros['qtdPagina'].toString();
      _paginaLeituraController.text =
          existingLivros['paginaLeitura'].toString();
      _lidoController =
          existingLivros['lido'].toString() == 'true' ? true : false;
      _qtdLidoController.text = existingLivros['qtdLido'].toString();
      _favoritoController =
          existingLivros['favorito'].toString() == 'true' ? true : false;
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _isbnController,
                    decoration: const InputDecoration(labelText: 'ISBN'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _autorController,
                    decoration: const InputDecoration(labelText: 'Autor'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'T??tulo'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _anoController,
                    decoration: const InputDecoration(labelText: 'Ano'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _qtdPaginaController,
                    decoration: const InputDecoration(labelText: 'P??ginas'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _paginaLeituraController,
                    decoration:
                        const InputDecoration(labelText: '??ltima p??gina lida'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  StatefulBuilder(
                    builder: (context, state) => CheckboxListTile(
                      title: const Text("Favorito?"),
                      value: _favoritoController,
                      onChanged: (newValue) {
                        state(() => _favoritoController = newValue);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      checkColor: Colors.red,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Update livro
                      if (id != null) {
                        _updateLivro(id);
                      }

                      // Clear the text fields
                      _isbnController.text = '';
                      _autorController.text = '';
                      _tituloController.text = '';
                      _anoController.text = '';
                      _qtdPaginaController.text = '';
                      _paginaLeituraController.text = '';
                      _lidoController = false;
                      _favoritoController = false;

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: const Text('Atualizar livro'),
                  )
                ],
              ),
            ));
  }

  // Update an existing livro
  Future<void> _updateLivro(int id) async {
    await SQLHelper.updateLivro(
        id,
        _isbnController.text,
        _autorController.text,
        _tituloController.text,
        _anoController.text.isEmpty ? 0 : int.parse(_anoController.text),
        _editoraController.text,
        _qtdPaginaController.text.isEmpty
            ? 0
            : int.parse(_qtdPaginaController.text),
        _paginaLeituraController.text.isEmpty
            ? 0
            : int.parse(_paginaLeituraController.text),
        _lidoController!,
        _qtdLidoController.text.isEmpty
            ? 0
            : int.parse(_qtdLidoController.text),
        _favoritoController!);
    _refreshLivros();
  }

  // Delete an livro
  void _deleteLivro(int id) {
    SQLHelper.deleteLivro(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Livro removido com sucesso!'),
    ));
    _refreshLivros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _livros.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text('T??tulo: ${_livros[index]['titulo']}'),
                    subtitle: Text(
                        '??ltima p??gina lida: ${_livros[index]['paginaLeitura']}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_livros[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteLivro(_livros[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
