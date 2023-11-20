import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  List<Note> _notes = [];
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  int? noteKey;
  int? noteIndex;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    List<Note> notes = await dbHelper.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _addNote() async {
    Note newNote = Note(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );
    int id = await dbHelper.insert(newNote);
    setState(() {
      newNote.id = id;
      _notes.add(newNote);
    });
    clearFields();
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateNote(int index, int key) async {
    Note updatedNote = Note(
      id: key,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
    );
    await dbHelper.update(updatedNote);
    setState(() {
      _notes[index] = updatedNote;
    });
    clearFields();
  }

  void _deleteNote(int index, int key) async {
    await dbHelper.delete(key);
    setState(() {
      _notes.removeAt(index);
    });
  }

  void clearFields() {
    nameController.clear();
    descriptionController.clear();
    noteIndex = null;
    noteKey = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Ali Asar Khowaja',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: nameController,
                        autofocus: false,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Name",
                          hintText: "Enter note name.",
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter some name.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        autofocus: false,
                        maxLines: 5,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Description",
                          hintText: "Enter some note description.",
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter some description.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (noteIndex == null || noteKey == null) {
                                showSnackbar(
                                    'To perform update operation, please select a note first.');
                                FocusScope.of(context).unfocus();
                              } else {
                                _updateNote(noteIndex!, noteKey!);
                                showSnackbar('Note updated successfully.');
                                FocusScope.of(context).unfocus();
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index].name),
                    subtitle: Text(_notes[index].description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            nameController.text = _notes[index].name;
                            descriptionController.text =
                                _notes[index].description;
                            noteIndex = index;
                            noteKey = _notes[index].id;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteNote(index, _notes[index].id!);
                            showSnackbar('Note deleted successfully.');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _addNote();
              showSnackbar('Note added successfully.');
              FocusScope.of(context).unfocus();
            }
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
