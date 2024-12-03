import 'package:flutter/material.dart';

class Allusers extends StatefulWidget {
  const Allusers({super.key});

  @override
  State<Allusers> createState() => _AllusersState();
}

class _AllusersState extends State<Allusers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: const Center(
        child: Text('All Users'),
      ),
    );
  }
}