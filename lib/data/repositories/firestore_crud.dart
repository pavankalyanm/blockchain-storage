import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/globals.dart' as globals;

class FireStoreCrud {
  FireStoreCrud();

  final _firestore = FirebaseFirestore.instance;

  Future<void> addTask({required TaskModel task}) async {
    var taskcollection = _firestore.collection('tasks');
    await taskcollection.add(task.tojson());
  }

  Stream<List<TaskModel>> getTasks({required String mydate}) {
    return _firestore
        .collection('tasks')
        .where('date', isEqualTo: mydate)
        .snapshots(includeMetadataChanges: true)
        .map((snapshor) => snapshor.docs
            .map((doc) => TaskModel.fromjson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateTask(
      {required String title,
      note,
      docid,
      date,
      starttime,
      endtime,
      required int reminder,
      colorindex}) async {
    var taskcollection = _firestore.collection('tasks');
    await taskcollection.doc(docid).update({
      'title': title,
      'note': note,
      'date': date,
      'starttime': starttime,
      'endtime': endtime,
      'reminder': reminder,
      'colorindex': colorindex,
    });
  }

  Future<void> deleteTask({required String docid}) async {
    var taskcollection = _firestore.collection('tasks');
    await taskcollection.doc(docid).delete();
  }

  Future<void> generateId(
      {required String uniqueId, required String classid}) async {
    var attendance = _firestore
        .collection('tattendance')
        .doc(uniqueId)
        .collection('attendance');
    QuerySnapshot querySnapshot = await _firestore
        .collection('class')
        .doc(classid)
        .collection('students')
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      DocumentSnapshot snapshot = await _firestore
          .collection('class')
          .doc(classid)
          .collection('students')
          .doc('${querySnapshot.docs[i].id}')
          .get();

      await attendance.doc(snapshot.id).set({
        "attendance": 'absent'
//        "document" : "default"
      });
      await _firestore
          .collection('class')
          .doc(classid)
          .collection('students')
          .doc('${querySnapshot.docs[i].id}')
          .collection('preattendance')
          .doc(uniqueId)
          .set({"attendance": "absent"});
    }
  }

  Future<void> attend({required code}) async {
    final prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('uid') ?? '';
    var roll;
    await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((value) => roll = value['roll']);

    debugPrint(roll);
    await _firestore
        .collection('tattendance')
        .doc(code)
        .collection('attendance')
        .doc(roll)
        .update({"attendance": 'present'});

    await _firestore
        .collection('class')
        .doc(globals.classcode)
        .collection('students')
        .doc(globals.roll)
        .collection('preattendance')
        .doc(code)
        .update({"attendance": 'present'});
  }

  Stream<List<TaskModel>> previousAttendance() {
    if (globals.role == 'student') {
      print('i am here see mee');
      return _firestore
          .collection('class')
          .doc(globals.classcode)
          .collection('students')
          .doc(globals.roll)
          .collection('preattendance')
          .snapshots(includeMetadataChanges: true)
          .map((snapshor) => snapshor.docs
              .map((doc) => TaskModel.fromjson(doc.data(), doc.id))
              .toList());
    }

    return _firestore
        .collection('tattendance')
        .snapshots(includeMetadataChanges: true)
        .map((snapshor) => snapshor.docs
            .map((doc) => TaskModel.fromjson(doc.data(), doc.id))
            .toList());
  }

  Future<void> loadDetails({required String? uid}) async {
    var user = _firestore.collection('users').doc(uid);
    await user.get().then((value) {
      globals.uid = uid;
      globals.classcode = value.data()!['classcode'];
      globals.role = value.data()!['role'];
      globals.roll = value.data()!['roll'];
      globals.name = value.data()!['fullname'];
    });
  }

  Future<void> checkRole({required String? uid}) async {
    var user = _firestore.collection('users').doc(uid);
    await user.get().then((value) {
      debugPrint(value.data()!['role']);
      globals.role = value.data()!['role'];
    });
  }
}
