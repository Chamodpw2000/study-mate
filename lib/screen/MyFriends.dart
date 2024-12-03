import 'package:flutter/material.dart';

class Myfriends extends StatefulWidget {
  const Myfriends({super.key});

  @override
  State<Myfriends> createState() => _MyfriendsState();
}

class _MyfriendsState extends State<Myfriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Friends'),
      ),
      body: const Center(
        child: Text('My Friends'),
      ),
    );
  }
}