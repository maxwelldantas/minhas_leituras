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
          primarySwatch: Colors.green,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class ParaLerWidget extends StatefulWidget {
  const ParaLerWidget({super.key});

  @override
  State<ParaLerWidget> createState() => _ParaLerTela();
}

class LidosWidget extends StatefulWidget {
  const LidosWidget({super.key});

  @override
  State<LidosWidget> createState() => _LidosTela();
}

class FavoritosWidget extends StatefulWidget {
  const FavoritosWidget({super.key});

  @override
  State<FavoritosWidget> createState() => _FavoritosTela();
}

class _ParaLerTela extends State<ParaLerWidget> {
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
  final TextEditingController _editoraController = TextEditingController();
  final TextEditingController _qtdPaginaController = TextEditingController();
  final TextEditingController _paginaLeituraController =
      TextEditingController();
  bool? _lidoController = false;
  final TextEditingController _qtdLidoController = TextEditingController();

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
      _qtdPaginaController.text = existingLivros['paginas'].toString();
      _paginaLeituraController.text =
          existingLivros['paginaLeitura'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (context) => Container(
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
                    controller: _qtdPaginaController,
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
                  CheckboxListTile(
                    title: Text("Livro lido?"),
                    value: _lidoController,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _lidoController = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
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
                      _qtdPaginaController.text = '';
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
            : int.parse(_qtdLidoController.text));
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
            : int.parse(_qtdLidoController.text));
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
        title: const Text('Para Ler'),
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
                    subtitle: Text('Página última leitura: ' +
                        _livros[index]['paginaLeitura'].toString()),
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

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _LidosTela extends State<LidosWidget> {
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
  final TextEditingController _editoraController = TextEditingController();
  final TextEditingController _qtdPaginaController = TextEditingController();
  final TextEditingController _paginaLeituraController =
  TextEditingController();
  final TextEditingController _lidoController = TextEditingController();
  final TextEditingController _qtdLidoController = TextEditingController();

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
      _qtdPaginaController.text = existingLivros['paginas'].toString();
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
                controller: _qtdPaginaController,
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
                  _qtdPaginaController.text = '';
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
        _editoraController.text,
        _qtdPaginaController.text.isEmpty
            ? 0
            : int.parse(_qtdPaginaController.text),
        _paginaLeituraController.text.isEmpty
            ? 0
            : int.parse(_paginaLeituraController.text),
        _lidoController.text == "Sim" ? true : false,
        _qtdLidoController.text.isEmpty
            ? 0
            : int.parse(_qtdLidoController.text));
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
        _editoraController.text,
        _qtdPaginaController.text.isEmpty
            ? 0
            : int.parse(_qtdPaginaController.text),
        _paginaLeituraController.text.isEmpty
            ? 0
            : int.parse(_paginaLeituraController.text),
        _lidoController.text == "Sim" ? true : false,
        _qtdLidoController.text.isEmpty
            ? 0
            : int.parse(_qtdLidoController.text));
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
        title: const Text('Lidos'),
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
              subtitle: Text('Página última leitura: ' +
                  _livros[index]['paginaLeitura'].toString()),
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

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _FavoritosTela extends State<FavoritosWidget> {
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
  final TextEditingController _editoraController = TextEditingController();
  final TextEditingController _qtdPaginaController = TextEditingController();
  final TextEditingController _paginaLeituraController =
  TextEditingController();
  final TextEditingController _lidoController = TextEditingController();
  final TextEditingController _qtdLidoController = TextEditingController();

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
      _qtdPaginaController.text = existingLivros['paginas'].toString();
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
                controller: _qtdPaginaController,
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
                  _qtdPaginaController.text = '';
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
        _editoraController.text,
        _qtdPaginaController.text.isEmpty
            ? 0
            : int.parse(_qtdPaginaController.text),
        _paginaLeituraController.text.isEmpty
            ? 0
            : int.parse(_paginaLeituraController.text),
        _lidoController.text == "Sim" ? true : false,
        _qtdLidoController.text.isEmpty
            ? 0
            : int.parse(_qtdLidoController.text));
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
        _editoraController.text,
        _qtdPaginaController.text.isEmpty
            ? 0
            : int.parse(_qtdPaginaController.text),
        _paginaLeituraController.text.isEmpty
            ? 0
            : int.parse(_paginaLeituraController.text),
        _lidoController.text == "Sim" ? true : false,
        _qtdLidoController.text.isEmpty
            ? 0
            : int.parse(_qtdLidoController.text));
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
              title: Text('Título: ' + _livros[index]['titulo']),
              subtitle: Text('Página última leitura: ' +
                  _livros[index]['paginaLeitura'].toString()),
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

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _HomePageState extends State<HomePage> {
  int _indiceAtual = 0; // Variável para controlar o índice das telas
  final List<Widget> _telas = [
    ParaLerWidget(),
    LidosWidget(),
    FavoritosWidget()
  ];

  void onTabTapped(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_indiceAtual], //Alterando posição da lista
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "Para Ler"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Lidos"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favoritos"),
        ],
      ),
    );
  }
}
