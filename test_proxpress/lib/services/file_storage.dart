import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';



class FileStorage {
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: "gs://proxpress-629e3.appspot.com");
  final String uid;
  FileStorage({this.uid});

  uploadFile(File file) async{
    var storageRef = storage.ref().child("customer/profile/${uid}");
    print(uid);
    var uploadTask = storageRef.putFile(file);
    var compleTask = await uploadTask;
    String downloadUrl = await compleTask.ref.getDownloadURL();
    return downloadUrl;
  }
}