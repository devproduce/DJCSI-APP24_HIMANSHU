import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notes_app/components/elevated_button.dart';
import 'package:notes_app/database/databaseHelperNotes.dart';
import 'package:notes_app/database/databaseNotes.dart';
import 'package:notes_app/theme/theme_constants.dart';
import 'package:notes_app/theme/theme_manager.dart';

class NotesAddScreen extends StatefulWidget {
  NotesAddScreen({super.key, required this.isDark, required this.isEdit});
  final bool isDark;
  final bool isEdit;
  int? id;
  NotesAddScreen.withId(
      {super.key,
      required this.isDark,
      required this.isEdit,
      required this.id});

  @override
  State<NotesAddScreen> createState() => _NotesAddScreenState();
}

class _NotesAddScreenState extends State<NotesAddScreen> {
  //final ThemeManager _themeManager = ThemeManager();
  Note? note;
  String _selectedOption = '';
  final NotesDatabaseHelper db = NotesDatabaseHelper();
  String? _errorText;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _loadNote() async {
    if (widget.isEdit) {
      // Debugging print
      note = await db.getNoteById(widget.id!);
      if (note != null) {
        // Debugging print
        setState(() {
          _titleController.text = note!.title;
          _descriptionController.text = note!.description;
          _selectedOption = note!.tag;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: widget.isDark ? darkTheme : lightTheme,
      darkTheme: widget.isDark ? darkTheme : lightTheme,
      home: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 7),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                backgroundColor: widget.isDark
                    ? WidgetStatePropertyAll(Color.fromRGBO(59, 59, 59, 1))
                    : WidgetStatePropertyAll(Color.fromRGBO(59, 59, 59, 0.25)),
                minimumSize: const WidgetStatePropertyAll<Size>(Size(35, 35)),
                maximumSize: const WidgetStatePropertyAll<Size>(Size(35, 35)),
                padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.only(left: 0, top: 0),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_outlined,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          actions: [
            widget.isEdit
                ? Row(
                    children: [
                      MyElevatedButton(
                        color: widget.isDark
                            ? Color.fromRGBO(59, 59, 59, 1)
                            : Color.fromRGBO(59, 59, 59, 0.25),
                        onTap: () async {
                          final selected = await showMenu<String>(
                            context: context,
                            position:
                                const RelativeRect.fromLTRB(100, 100, 0, 0),
                            items: const [
                              PopupMenuItem(
                                  value: '#personal',
                                  child: Text(
                                    '#personal',
                                    style: TextStyle(color: Colors.white),
                                  )),
                              PopupMenuItem(
                                  value: '#work',
                                  child: Text('#work',
                                      style: TextStyle(color: Colors.white))),
                              PopupMenuItem(
                                  value: '#ideas',
                                  child: Text('#ideas',
                                      style: TextStyle(color: Colors.white))),
                            ],
                          );

                          if (selected != null) {
                            setState(() {
                              _selectedOption = selected;
                            });
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _selectedOption == ''
                                ? const Icon(Icons.tag)
                                : Text(_selectedOption),
                          ],
                        ),
                      ),
                      MyElevatedButton(
                          color: widget.isDark
                              ? Color.fromRGBO(59, 59, 59, 1)
                              : Color.fromRGBO(59, 59, 59, 0.5),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Save changes?',
                                    style: TextStyle(
                                        color: widget.isDark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  backgroundColor: widget.isDark
                                      ? Colors.grey.shade900
                                      : Colors.white,
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      style: ButtonStyle(
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                          Colors.red, // Red color for Discard
                                        ),
                                      ),
                                      child: const Text('Discard'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        try {
                                          // Ensure the title is not empty
                                          if (_titleController.text.isEmpty) {
                                            throw Exception(
                                                "Title is required.");
                                          }

                                          // Ensure the tag is selected (not empty)
                                          if (_selectedOption == '') {
                                            throw Exception("Tag is required.");
                                          }

                                          // Description is optional, so it's not mandatory to check here
                                          note = Note.withId(
                                            title: _titleController.text,
                                            description: _descriptionController
                                                    .text.isNotEmpty
                                                ? _descriptionController.text
                                                : '',
                                            tag: _selectedOption,
                                            id: widget.id,
                                          );

                                          // Insert the note into the database
                                          db.updateNote(note!);

                                          // Navigate back to the first screen
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                        } catch (e) {
                                          if (_titleController.text.isEmpty) {
                                            setState(() {
                                              _errorText =
                                                  'Title Cannot be Empty';
                                            });
                                          } else {
                                            setState(() {
                                              _errorText = 'Select A Tag';
                                            });
                                          }

                                          Navigator.pop(context);
                                        }
                                      },
                                      style: ButtonStyle(
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                          Colors.green, // Green color for Save
                                        ),
                                      ),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ))
                    ],
                  )
                : Row(
                    children: [
                      MyElevatedButton(
                        color: widget.isDark
                            ? Color.fromRGBO(59, 59, 59, 1)
                            : Color.fromRGBO(59, 59, 59, 0.5),
                        onTap: () async {
                          final selected = await showMenu<String>(
                            context: context,
                            position:
                                const RelativeRect.fromLTRB(100, 100, 0, 0),
                            items: const [
                              PopupMenuItem(
                                  value: '#personal',
                                  child: Text(
                                    '#personal',
                                    style: TextStyle(color: Colors.grey),
                                  )),
                              PopupMenuItem(
                                  value: '#work',
                                  child: Text(
                                    '#work',
                                    style: TextStyle(color: Colors.grey),
                                  )),
                              PopupMenuItem(
                                value: '#ideas',
                                child: Text(
                                  '#ideas',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          );

                          if (selected != null) {
                            setState(() {
                              _selectedOption = selected;
                            });
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _selectedOption == ''
                                ? const Icon(Icons.tag, color: Colors.white)
                                : Text(
                                    _selectedOption,
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ],
                        ),
                      ),
                      MyElevatedButton(
                        color: widget.isDark
                            ? Color.fromRGBO(59, 59, 59, 1)
                            : Color.fromRGBO(59, 59, 59, 0.25),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Save changes?',
                                  style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                backgroundColor: widget.isDark
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                        Colors.red, // Red color for Discard
                                      ),
                                    ),
                                    child: const Text('Discard'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      try {
                                        // Ensure the title is not empty
                                        if (_titleController.text.isEmpty) {
                                          throw Exception("Title is required.");
                                        }

                                        // Ensure the tag is selected (not empty)
                                        if (_selectedOption == '') {
                                          throw Exception("Tag is required.");
                                        }

                                        // Description is optional, so it's not mandatory to check here
                                        note = Note(
                                          title: _titleController.text,
                                          description: _descriptionController
                                                  .text.isNotEmpty
                                              ? _descriptionController.text
                                              : '',
                                          tag: _selectedOption,
                                        );

                                        // Insert the note into the database
                                        db.insertNote(note!);

                                        // Navigate back to the first screen
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      } catch (e) {
                                        if (_titleController.text.isEmpty) {
                                          setState(() {
                                            _errorText =
                                                'Title Cannot be Empty';
                                          });
                                        } else {
                                          setState(() {
                                            _errorText = 'Select A Tag';
                                          });
                                        }

                                        Navigator.pop(context, true);
                                        // Handle any exceptions

                                        // Optionally, show an error message to the user using a Snackbar or Dialog
                                      }
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                        Colors.green, // Green color for Save
                                      ),
                                    ),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.save, color: Colors.white),
                      ),
                    ],
                  )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              child: TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 40,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: 'Title',
                  errorText: _errorText,
                ),
                maxLines: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: TextField(
                controller: _descriptionController,
                style: TextStyle(
                  fontSize: 20,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
                decoration: const InputDecoration(
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: 'Type Something..',
                ),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
