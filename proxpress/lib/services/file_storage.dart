import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileStorage {
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: "gs://proxpress-629e3.appspot.com");
  final String uid;
  FileStorage({this.uid});

  uploadFile(File file) async{
    var storageRef = storage.ref().child("customer/profile/${uid}");
    print(uid);
    var uploadTask = storageRef.putFile(file);
    var completeTask = await uploadTask;
    String downloadUrl = await completeTask.ref.getDownloadURL();
    return downloadUrl;
  }
}