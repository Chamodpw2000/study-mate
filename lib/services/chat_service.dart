import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    await _updateChatRoom(chatRoomId, receiverId, message, timestamp);
  }

  Future<void> _updateChatRoom(
    String chatRoomId,
    String receiverId,
    String lastMessage,
    Timestamp timestamp,
  ) async {
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': [_firebaseAuth.currentUser!.uid, receiverId],
      'lastMessage': lastMessage,
      'lastMessageTime': timestamp,
      'unreadCount_$receiverId': true,
    }, SetOptions(merge: true));
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    List<String> ids = [_firebaseAuth.currentUser!.uid, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'unreadCount_${_firebaseAuth.currentUser!.uid}': false,
    });
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }
}
