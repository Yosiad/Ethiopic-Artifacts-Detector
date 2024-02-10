import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'Descriptions.dart'; // Import your ProductItemScreen file

class DetectionPage extends StatefulWidget {
  final File? croppedImage;

  const DetectionPage({Key? key, this.croppedImage}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class DetectedObject {
  final String name;
  final String description;

  DetectedObject(this.name, this.description);

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      json['name'] ?? '',
      json['description'] ?? '',
    );
  }
}

class _DetectionPageState extends State<DetectionPage> {
  late Future<List<DetectedObject>> results;
  String? newImageFilename;

  @override
  void initState() {
    super.initState();
    if (widget.croppedImage != null) {
      results = sendImageToServer(widget.croppedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detection'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<List<DetectedObject>>(
                future: results,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // Display the processed image
                    return Column(
                      children: [
                        Container(
                          height:
                              300.0, // Adjust the height based on your needs
                          child: Image.network(
                            'http://192.168.212.126:5000/get_image/$newImageFilename',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Objects Detected:',
                          style: TextStyle(fontSize: 18),
                        ),
                        // Use a ListView.builder for the detected objects
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              snapshot.data!.length,
                              (index) {
                                var object = snapshot.data![index];
                                return GestureDetector(
                                  onTap: () {
                                    navigateToProductItemScreen(object.name);
                                  },
                                  child: buildScrollableCard(object),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text('No image URL available');
                  }
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScrollableCard(DetectedObject object) {
    Color cardColor = Colors.white; // Default color

    // Set color based on object name
    if (object.name == 'Jebena') {
      cardColor = Colors.red;
    } else if (object.name == 'Sini') {
      cardColor = Colors.green;
    }

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              getImageAsset(object.name),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            object.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String getImageAsset(String key) {
    switch (key) {
      case 'Jebena':
        return 'assets/jebena.png';
      case 'Sini':
        return 'assets/Sini.jpg';
      default:
        return 'assets/default_image.jpg';
    }
  }

  void navigateToProductItemScreen(String objectName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductItemScreen(objectName: objectName),
      ),
    );
  }

  Future<File> rotateImage(File imgFile, int degrees) async {
    img.Image image = img.decodeImage(await imgFile.readAsBytes())!;
    img.Image rotatedImage = img.copyRotate(image, angle: degrees);
    File rotatedFile = File('${imgFile.path}_rotated_$degrees.jpg');
    await rotatedFile.writeAsBytes(img.encodeJpg(rotatedImage));
    return rotatedFile;
  }

  Future<List<DetectedObject>> sendImageToServer(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.212.126:5000'),
      );
     
      File rotatedImage = await rotateImage(imageFile, 360);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Update the field name to match your server
          rotatedImage.path,
        ),
      );
      var response = await request.send();



      if (response.statusCode == 200) {
        print("success 1");
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> result = json.decode(responseData);
        print("success 2");
        newImageFilename = result['image_path']
            as String; // Receive the filename from the server
        List<String> namesList = (result['names'] as List).cast<String>();
        List<DetectedObject> detectedObjects = namesList.map((name) {
          return DetectedObject(
              name, ''); // Provide a description or handle it as needed
        }).toList();

        return detectedObjects;
      } else {
        throw 'Failed to upload image. Status code: ${response.statusCode}';
      }
    } catch (error) {
      throw 'Error uploading image: $error';
    }
  }
}
