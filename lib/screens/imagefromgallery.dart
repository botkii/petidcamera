import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageFromGalleryEx extends StatefulWidget {
  final type;
  ImageFromGalleryEx(this.type);

  @override
  ImageFromGalleryExState createState() => ImageFromGalleryExState(this.type);
}

class ImageFromGalleryExState extends State<ImageFromGalleryEx> {
  var _image;
  var imagePicker;
  var type;

  ImageFromGalleryExState(this.type);

  String results = '';

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  Future<void> getImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://b1fb-2600-4041-50e2-ac00-58ed-f9f3-9815-d91a.ngrok.io/predict'));
    request.files.add(
        await http.MultipartFile.fromPath('file', pickedFile.path.toString()));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      results = await response.stream.bytesToString();
      print(results);
    } else {
      print(response.reasonPhrase);
    }

    showResults();
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> showResults() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Breed Percentage"),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              Text(results),
            ])),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image from Gallery")),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 52,
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                await getImage();
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 154, 226, 239)),
                child: _image != null
                    ? Image.file(
                        _image,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitHeight,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 154, 226, 239)),
                        width: 200,
                        height: 200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(
            height: 52,
          ),
          ElevatedButton(
            onPressed: clearImage,
            child: const Text('Clear Image'),
          ),
        ],
      ),
    );
  }
}
