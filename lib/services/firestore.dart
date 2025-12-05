import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of data
  final CollectionReference dustbin = FirebaseFirestore.instance.collection(
    "dustbin",
  );

  // Create: Add a new note

  Future<void> addDustbinStatus() {
    return dustbin.add({
      'createdAt': Timestamp.now(),
      'distance_cm': 234.1661,
      'last_update_ms': 2406449,
      'level': 50,
      'status': "Empty",
      'location': "Main Office, 1st floor.",
    });
  }

  // Read: get notes from database

  Stream<QuerySnapshot> getDustbinStream() {
    final dustbinStream = dustbin
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots();
    return dustbinStream;
  }

  // update: update notes give a doc id

  // Delete: delete notes give a doc id
}
