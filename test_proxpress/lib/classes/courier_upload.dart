import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:proxpress/UI/signup_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/upload_file.dart';

class CourierUpload extends StatefulWidget {
  @override
  _CourierUploadState createState() => _CourierUploadState();
}

class _CourierUploadState extends State<CourierUpload> {
  File file;
  final Courier _courier = Courier();

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null){
    }
    final path = result.files.single.path;
    setState(() {
      file = File(path);
    });
    //SignupCourier(uploadfile: uploadFile);
  }

  Future uploadFile() async {
    final fileName = Path.basename(file.path);
    final destination = 'Courier Credentials/$fileName';

    UploadFile.uploadFile(destination, file);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? Path.basename(file.path) : 'No File Selected';
    return Column(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: ElevatedButton.icon(
            icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
            label: Text(
              'Add File',
              style: TextStyle(color: Color(0xfffb0d0d)),
            ),
            onPressed: () {
              selectFile();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(fileName),
        ),
        // Align(
        //   alignment: Alignment.bottomLeft,
        //   child: ElevatedButton.icon(
        //     icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
        //     label: Text(
        //       'Upload File',
        //       style: TextStyle(color: Color(0xfffb0d0d)),
        //     ),
        //     onPressed: () {
        //       uploadFile();
        //     },
        //     style: ElevatedButton.styleFrom(
        //       primary: Colors.white,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
