import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  var imagePicker;
  var picture;
  List<CameraDescription> cameras = [];

  Future<void> getCamera() async {
    cameras = await availableCameras();
  }

  String results = '';

  Future<void> getImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        picture = File(pickedFile.path);
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
  void initState() {
    getCamera();
    super.initState();
    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await initializeControllerFuture;
            picture = await controller.takePicture();
            if (!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: picture.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
