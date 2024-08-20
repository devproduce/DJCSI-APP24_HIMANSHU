import 'package:notes_app/database/databaseHelperNotes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesDatabaseHelper {
  static final NotesDatabaseHelper _instance = NotesDatabaseHelper._internal();
  factory NotesDatabaseHelper() => _instance;

  static Database? _database;
  final String _tableName = 'notes';

  NotesDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notesfor.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        tag TEXT NOT NULL
      )
    ''');
  }

  // Insert a new note into the database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    return await db.insert(_tableName, note.noteToMap());
  }

  // Update an existing note in the database
  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      _tableName,
      note.noteToMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note from the database
  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Retrieve a note by its id
  Future<Note?> getNoteById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Note.mapToNote(result.first);
    } else {
      return null;
    }
  }

  // Retrieve all notes
  Future<List<Note>> getAllNotes() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(_tableName);

    return result.map((map) => Note.mapToNote(map)).toList();
  }

  // Retrieve notes by a specific tag
  Future<List<Note>> getNotesByTag(String tag) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'tag = ?',
      whereArgs: [tag],
    );

    return result.map((map) => Note.mapToNote(map)).toList();
  }

  // Search notes by title or description
  Future<List<Note>> searchNotes(String query) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((map) => Note.mapToNote(map)).toList();
  }
}
