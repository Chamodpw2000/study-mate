import 'package:flutter/material.dart';

class FavNotes extends StatefulWidget {
  const FavNotes({super.key});

  @override
  State<FavNotes> createState() => _FavNotesState();
}

class _FavNotesState extends State<FavNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Notes'),
      ),
      body: const Center(
        child: Text('Favourite Notes'),
      ),
    );
  }
}