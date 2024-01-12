import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        title: Text('Detection Page'),
      ),
      body: Center(
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
                  if (newImageFilename!.isNotEmpty) {
                    return Column(
                      children: [
                        Image.asset(
                          './assets/$newImageFilename',  
                          height: 200, 
                        ),  // Display the processed image
                        const SizedBox(height: 20.0),
                        Text(
                          'Objects Detected:',
                          style: TextStyle(fontSize: 18),
                        ),
                        for (var object in snapshot.data!)
                          Column(
                            children: [
                              Text(
                                '- ${object.name}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Description: ${object.description}',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 10.0),
                            ],
                          ),
                      ],
                    );
                  } else {
                    return Text('No image URL available');
                  }
                } else {
                  return Text('No objects detected');
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
    );
  }

  Future<List<DetectedObject>> sendImageToServer(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/'), 
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',  // Update the field name to match your server
          imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) { 
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> result = json.decode(responseData);

        newImageFilename = result['image_path'] as String ; // Receive the filename from the server

        List<dynamic> jsonList = result['names'];
        return jsonList.map((jsonObject) => DetectedObject.fromJson(jsonObject)).toList();
      } else {
        throw 'Failed to upload image. Status code: ${response.statusCode}';
      }
    } catch (error) {
      throw 'Error uploading image: $error'; 
    }
  }
}