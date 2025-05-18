import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(String note){
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getNotes() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateNote(String docId, String note) {
    return notes.doc(docId).update({
      'note': note,
      'timestamp': Timestamp.now(), 
    });
  } 

  Future<void> deleteNote(String docId) {
    return notes.doc(docId).delete();
  }
}