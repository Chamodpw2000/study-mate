import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screen/AllUsers.dart';
import 'package:studymate/screen/FriendRequests.dart';
import 'package:studymate/screen/MyFriends.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Friends(),
    );
  }
}

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  int currentIndex = 1;
  final screens = [
    const Allusers(),
    const Myfriends(),
    const Friendrequests(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) => setState(() {
            currentIndex = value; // Update the selected screen
          }),
          iconSize: 30,
          selectedFontSize: 20,
          currentIndex: currentIndex,
          backgroundColor: Colors.grey.withOpacity(0.3),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Find Friends",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "My Friends ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_add),
              label: "Requests",
            ),
          ],
        ));
  }
}
