import 'package:flutter/material.dart';

class Friendrequests extends StatefulWidget {
  const Friendrequests({super.key});

  @override
  State<Friendrequests> createState() => _FriendrequestsState();
}

class _FriendrequestsState extends State<Friendrequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: const Center(
        child: Text('Friend Requests'),
      ),
    );
  }
}
