import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_journal/components/common.dart';
import 'package:my_journal/helper/common.dart';
import 'package:my_journal/models/journal_model.dart';
import 'package:my_journal/repository/journal_repository.dart';

class JournalInput extends StatefulWidget {
  JournalModel? journal;

  JournalInput({super.key, this.journal});

  @override
  State<JournalInput> createState() => _JournalInputState();
}

class _JournalInputState extends State<JournalInput> {
  JournalRepository journalRepository = JournalRepository();
  final Map<String, dynamic> _journal = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'mood': '',
    'location': TextEditingController(),
    'images': <String>[],
    'waktu': DateTime.now(),
  };
  final List<String> _moods = <String>['Happy', 'Sad', 'Angry', 'Excited'];
  bool isEdit = false;

  @override
  void initState() {
    if (widget.journal != null) {
      _journal['title'].text = widget.journal!.title;
      _journal['description'].text = widget.journal!.description!;
      _journal['mood'] = widget.journal!.mood!;
      _journal['location'].text = widget.journal!.location!;
      _journal['images'] = widget.journal!.images;
      _journal['waktu'] = widget.journal!.waktu;
      isEdit = true;
    }

    super.initState();
  }

  @override
  void dispose() {
    _journal['title'].dispose();
    _journal['description'].dispose();
    super.dispose();
  }

  Future<void> _pickImages(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb,
      );

      if (result != null) {
        List<String> base64Images;

        if (kIsWeb) {
          base64Images = result.files.map((file) {
            Uint8List? fileBytes = file.bytes;
            return base64Encode(fileBytes!);
          }).toList();
        } else {
          List<File> files =
              result.paths.map((String? path) => File(path!)).toList();
          base64Images = files.map((File file) {
            List<int> imageBytes = file.readAsBytesSync();
            return base64Encode(imageBytes);
          }).toList();
        }

        setState(() {
          if (_journal['images'].isEmpty) {
            _journal['images'] = base64Images;
          } else {
            _journal['images'].addAll(base64Images);
          }

          if (_journal['images'].length > 5) {
            ShowSnackBar().show(context, 'Maksimal 5 gambar');
            _journal['images'] = _journal['images'].sublist(0, 5);
          }
        });
      }
    } catch (e) {
      ShowSnackBar().show(context, 'Gagal memilih gambar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            'Tambah Jurnal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        toolbarHeight: 80,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              if (_journal['images'].isEmpty)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: TextButton(
                        onPressed: () {
                          _pickImages(context);
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                        child: const Icon(Icons.add_a_photo)),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _journal['images'].length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                        child: Stack(
                          children: [
                            Image.memory(
                              base64Decode(_journal['images'][index]),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(Icons.delete_rounded,
                                    color: Colors.red),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _journal['images'].removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _journal['title'],
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.title),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _journal['description'],
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.description),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                onChanged: (String? value) {
                  setState(() {
                    _journal['mood'] = value!;
                  });
                },
                items: _moods.map((String mood) {
                  return DropdownMenuItem<String>(
                    value: mood,
                    child: Text(mood),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _journal['location'],
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.location_on),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateHelper().formatDate(_journal['waktu']),
                ),
                decoration: const InputDecoration(
                  labelText: 'Waktu',
                  border: OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.calendar_today),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _journal['waktu'],
                    firstDate: DateTime(1980),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _journal['waktu'] = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_journal['images'].isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _pickImages(context);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.add_a_photo),
                        SizedBox(width: 8),
                        Text('Tambah Gambar'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    JournalModel journal = JournalModel(
                      id: isEdit
                          ? widget.journal!.id
                          : DateTime.now().toString(),
                      title: _journal['title'].text,
                      description: _journal['description'].text,
                      mood: _journal['mood'],
                      location: _journal['location'].text,
                      images: _journal['images'],
                      waktu: _journal['waktu'],
                    );

                    if (validateData(journal) == false) {
                      ShowSnackBar()
                          .show(context, 'Judul dan gambar tidak boleh kosong');
                      return;
                    }

                    if (isEdit) {
                      await journalRepository.update(journal);
                    } else {
                      await journalRepository.store(journal);
                    }

                    Navigator.pop(context, true);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text('Simpan'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.cancel),
                      SizedBox(width: 8),
                      Text('Batal'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  validateData(JournalModel journal) {
    if (journal.title.isEmpty || journal.images.isEmpty) {
      return false;
    }
    return true;
  }
}
