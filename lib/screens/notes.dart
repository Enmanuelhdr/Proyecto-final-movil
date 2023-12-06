import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class Note {
  int id;
  String title;
  String content;

  Note({required this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }
}

class DatabaseHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'notes.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNote(Note note) async {
    await _database.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final List<Map<String, dynamic>> maps = await _database.query('notes');
    return List.generate(maps.length, (index) {
      return Note(
        id: maps[index]['id'],
        title: maps[index]['title'],
        content: maps[index]['content'],
      );
    });
  }

  Future<void> updateNote(Note note) async {
    await _database.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(int id) async {
    await _database.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late List<Note> _notes = [];  // Inicializar _notes como una lista vacía

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _databaseHelper.initializeDatabase();
    await _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final notes = await _databaseHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty && content.isNotEmpty) {
      final newNote = Note(
        id: 0,
        title: title,
        content: content,
      );
      await _databaseHelper.insertNote(newNote);
      _refreshNotes();
      _clearInputFields();
    }
  }

  Future<void> _updateNote(Note note) async {
    await _databaseHelper.updateNote(note);
    _refreshNotes();
  }

  Future<void> _deleteNote(int id) async {
    await _databaseHelper.deleteNote(id);
    _refreshNotes();
  }

  void _clearInputFields() {
    _titleController.clear();
    _contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addNote,
              child: const Text('Add Note'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      onTap: () {
                        // Open a dialog to edit the note
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Edit Note'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: TextEditingController(text: note.title),
                                    onChanged: (value) {
                                      note.title = value;
                                    },
                                    decoration: const InputDecoration(labelText: 'Title'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: TextEditingController(text: note.content),
                                    onChanged: (value) {
                                      note.content = value;
                                    },
                                    decoration: const InputDecoration(labelText: 'Content'),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateNote(note);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Save Changes'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      onLongPress: () {
                        // Delete the note on long press
                        _deleteNote(note.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotesScreen(),
    );
  }
}
