import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? realImage;
  final ImagePicker picker = ImagePicker();
  String imagePath = "";

  Future getImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      realImage = File(image!.path);
    });
  }

  //

  Future upload(File imageFile) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://206d-2600-4041-50e2-ac00-58ed-f9f3-9815-d91a.ngrok.io/predict?='));
    request.files.add(await http.MultipartFile.fromPath(
        imageFile.toString(), imageFile.path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'Upload an image of your pet!',
          ),
          SizedBox(height: 30),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
