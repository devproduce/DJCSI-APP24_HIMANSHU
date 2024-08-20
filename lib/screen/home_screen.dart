import 'package:flutter/material.dart';
import 'package:notes_app/components/elevated_button.dart';
import 'package:notes_app/database/databaseHelperNotes.dart';
import 'package:notes_app/database/databaseNotes.dart';
import 'package:notes_app/screen/notes_add_screen.dart';
import 'package:notes_app/theme/theme_constants.dart';
import 'package:notes_app/theme/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  ThemeManager _themeManager = ThemeManager();
  NotesDatabaseHelper db = NotesDatabaseHelper();
  List<Note> noteList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<int, bool> isDeletingMap = {}; // Track deleting state for each note by its ID

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  Future<void> getDatabase() async {
    try {
      noteList = await db.getAllNotes();
      setState(() {
        // Reset isDeletingMap when notes are refreshed
        isDeletingMap.clear();
        noteList.forEach((note) {
          isDeletingMap[note.id!] = false; // Initially, no note is in deleting state
        });
      });
    } catch (e) {
      print("Error fetching notes: $e");
    }
  }

  void _onSearchChanged(String query) async {
    List<Note> notes;

    if (query.isEmpty) {
      notes = await db.getAllNotes();
    } else {
      notes = await db.searchNotes(query);
    }

    setState(() {
      noteList = notes;
      notes.forEach((note) {
        isDeletingMap[note.id!] = false; // Reset deleting state when search changes
      });
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      getDatabase(); // Reset to original list
    });
  }

  void toggleDeleteMode(int noteId) {
    setState(() {
      isDeletingMap[noteId] = !(isDeletingMap[noteId] ?? false); // Toggle delete state
    });
  }

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? darkTheme : lightTheme,
      darkTheme: isDarkMode ? darkTheme : lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  cursorColor: isDarkMode ? Colors.white : Colors.black,
                  onChanged: (value) {
                    _onSearchChanged(value);
                  },
                )
              : const Text('Notes'),
          actions: [
            if (_isSearching)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _stopSearch,
                color: isDarkMode ? Colors.white : Colors.black,
              )
            else
              MyElevatedButton(
                onTap: _startSearch,
                child: const Icon(Icons.search, color: Colors.white),
                color: isDarkMode
                    ? Color.fromRGBO(59, 59, 59, 1)
                    : Color.fromRGBO(59, 59, 59, 0.5),
              ),
            MyElevatedButton(
              onTap: toggleTheme,
              child: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              color: isDarkMode
                  ? Color.fromRGBO(59, 59, 59, 1)
                  : Color.fromRGBO(59, 59, 59, 0.5),
            ),
          ],
        ),
        body: Stack(
          children: [
            noteList.isEmpty
                ? const Center(child : Image(image: AssetImage('assets/images/Notebook-rafiki.png') ))
                : ListView.builder(
                    itemCount: noteList.length,
                    itemBuilder: (context, index) {
                      final note = noteList[index];
                      final isDeleting = isDeletingMap[note.id] ?? false;

                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 4.0,
                          child: ListTile(
                            title: isDeleting
                                ? const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 40,
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    child: Text(
                                      note.title,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w400,
                                        color: isDarkMode
                                            ? Colors.black
                                            : Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            tileColor: isDeleting
                                ? Colors.red.shade400
                                : note.tag == '#work'
                                    ? Color.fromRGBO(145, 244, 143, 1)
                                    : note.tag == '#personal'
                                        ? Colors.lightBlue
                                        : Colors.red.shade400,
                            onTap: () {
                              if (isDeleting) {
                                // If in deleting mode, reset back to normal
                                db.deleteNote(note.id!);
                                getDatabase();
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotesAddScreen.withId(
                                        isDark: isDarkMode,
                                        isEdit: true,
                                        id: note.id,
                                      ),
                                    )).then((_) {
                                  getDatabase();
                                });
                              }
                            },
                            onLongPress: () {
                              if (isDeleting) {
                                toggleDeleteMode(note.id!);
                                // Delete the note if already in deleting mode
                                
                              } else {
                                // Enter deleting mode
                                toggleDeleteMode(note.id!);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor:
                    isDarkMode ? Colors.grey.shade900 : Colors.grey.shade500,
                elevation: 5,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotesAddScreen(
                        isDark: isDarkMode,
                        isEdit: false,
                      ),
                    ),
                  ).then((_) {
                    getDatabase();
                  });
                },
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}