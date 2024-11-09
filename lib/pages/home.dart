import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_journal/components/common.dart';
import 'package:my_journal/helper/common.dart';
import 'package:my_journal/models/journal_model.dart';
import 'package:my_journal/pages/journal_input.dart';
import 'package:my_journal/repository/journal_repository.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final JournalRepository _repository = JournalRepository();
  Key key = UniqueKey();
  List<JournalModel> _journals = [];

  @override
  void initState() {
    super.initState();
    _fetchJournals(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            'Journal',
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 35.0),
                  onPressed: () {
                    _fetchJournals(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 35.0),
                  onPressed: () async {
                    await inputJournal(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _journals.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _journals.length,
                    itemBuilder: (context, index) {
                      final journal = _journals[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  child: _buildImages(journal),
                                ),
                                const SizedBox(height: 8.0),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 8.0,
                                    bottom: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTitleDate(journal),
                                      const SizedBox(height: 16.0),
                                      Container(
                                        color: Colors.grey,
                                        height: 0.2,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildDescMoodLocation(
                                              journal, context),
                                          _buildPopupButton(journal, context),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book,
                        size: 100.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Belum ada jurnal',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextButton(
                          onPressed: () async {
                            await inputJournal(context);
                          },
                          child: const Text('Tambah Jurnal')),
                    ],
                  )),
                ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Future<void> inputJournal(BuildContext context) async {
    bool shouldrefresh = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => JournalInput()));
    if (shouldrefresh == true) {
      _fetchJournals(context);
      ShowSnackBar().show(context, 'Jurnal berhasil ditambahkan');
    }
  }

  Row _buildTitleDate(JournalModel journal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          journal.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21.0,
          ),
        ),
        Text(
          DateHelper().formatDate(journal.waktu),
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Column _buildDescMoodLocation(JournalModel journal, BuildContext context) {
    double screenMediaQuery = MediaQuery.of(context).size.width * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: screenMediaQuery,
          child: Text(
            journal.description == '' || journal.description == null
                ? 'Tidak ada deskripsi'
                : journal.description!,
            style: const TextStyle(
              fontSize: 15.0,
              color: Colors.grey,
            ),
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          formatMoodLocation(journal.mood, journal.location),
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  PopupMenuButton<String> _buildPopupButton(
      JournalModel journal, BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) async {
        if (value == 'delete') {
          bool shouldDelete = await _deleteJournal(journal);
          if (shouldDelete == true) {
            await _repository.delete(journal.id);
            _fetchJournals(context);
            ShowSnackBar().show(context, 'Jurnal berhasil dihapus');
          }
        } else if (value == 'edit') {
          bool shouldrefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalInput(journal: journal),
            ),
          );
          if (shouldrefresh == true) {
            _fetchJournals(context);
            ShowSnackBar().show(context, 'Jurnal berhasil diubah');
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8.0),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 8.0),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  Padding _buildImages(JournalModel journal) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: journal.images.length,
          itemBuilder: (context, index) {
            final image = journal.images[index];
            return SizedBox(
              width: 200,
              height: 200,
              child: Padding(
                padding: index != journal.images.length - 1
                    ? const EdgeInsets.only(right: 8.0)
                    : const EdgeInsets.all(0),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust the radius as needed
                  child: Image.memory(
                    base64Decode(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _fetchJournals(context) async {
    final journals = await _repository.index();

    setState(() {
      _journals = journals;
    });
  }

  String formatMoodLocation(String? mood, String? location) {
    if (mood == null || mood.isEmpty) {
      return location == null || location.isEmpty ? '' : location;
    } else {
      return location == null || location.isEmpty ? mood : '$mood | $location';
    }
  }

  Future<bool> _deleteJournal(JournalModel journal) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Konfirmasi'),
              content:
                  const Text('Apakah Anda yakin ingin menghapus jurnal ini?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
