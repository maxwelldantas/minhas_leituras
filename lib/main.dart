import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'repository/database/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Minhas Leituras',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All livros
  List<Map<String, dynamic>> _livros = [];

  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshLivros() async {
    final data = await SQLHelper.getLivros();
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
  final TextEditingController _paginasController = TextEditingController();
  final TextEditingController _paginaLeituraController =
      TextEditingController();

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
      _paginasController.text = existingLivros['paginas'].toString();
      _paginaLeituraController.text =
          existingLivros['paginaLeitura'].toString();
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
                    decoration: const InputDecoration(hintText: 'ISBN'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _autorController,
                    decoration: const InputDecoration(hintText: 'Autor'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _tituloController,
                    decoration: const InputDecoration(hintText: 'Título'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _anoController,
                    decoration: const InputDecoration(hintText: 'Ano'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _paginasController,
                    decoration: const InputDecoration(hintText: 'Páginas'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _paginaLeituraController,
                    decoration: const InputDecoration(
                        hintText: 'Página última leitura'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new livro
                      if (id == null) {
                        await _addLivro();
                      }

                      if (id != null) {
                        await _updateLivro(id);
                      }

                      // Clear the text fields
                      _isbnController.text = '';
                      _autorController.text = '';
                      _tituloController.text = '';
                      _anoController.text = '';
                      _paginasController.text = '';
                      _paginaLeituraController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new livro to the database
  Future<void> _addLivro() async {
    await SQLHelper.createLivro(
        _isbnController.text,
        _autorController.text,
        _tituloController.text,
        _anoController.text.isEmpty ? 0 : int.parse(_anoController.text),
        _paginasController.text.isEmpty
            ? 0
            : int.parse(_paginasController.text));
    _refreshLivros();
  }

  // Update an existing livro
  Future<void> _updateLivro(int id) async {
    await SQLHelper.updateLivro(
        id,
        _isbnController.text,
        _autorController.text,
        _tituloController.text,
        _anoController.text.isEmpty ? 0 : int.parse(_anoController.text),
        _paginasController.text.isEmpty
            ? 0
            : int.parse(_paginasController.text),
        _paginaLeituraController.text.isEmpty
            ? 0
            : int.parse(_paginaLeituraController.text));
    _refreshLivros();
  }

  // Delete an livro
  void _deleteLivro(int id) async {
    await SQLHelper.deleteLivro(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Livro removido com sucesso!'),
    ));
    _refreshLivros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Leituras'),
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
                    title: Text('Título: ' + _livros[index]['titulo']),
                    subtitle: Text('Página última leitura: ' + _livros[index]['paginaLeitura'].toString()),
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
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
