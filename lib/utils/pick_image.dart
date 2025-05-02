import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File?> pickImage(BuildContext context) async {
  return showDialog<File>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Image Source'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  Navigator.of(context).pop(File(picked.path));
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.photo_library, size: 30),
                  SizedBox(height: 8),
                  Text('Gallery'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (picked != null) {
                  Navigator.of(context).pop(File(picked.path));
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.camera_alt, size: 30),
                  SizedBox(height: 8),
                  Text('Camera'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<String?> getImageLink(
  File pickedImage,
  String dir,
  String fileName,
) async {
  try {
    // Step 1: Compress image
    final compressedImage = await compressImage(pickedImage, fileName);

    if (compressedImage == null) {
      print('Compression failed.');
      return null;
    }

    // Step 2: Upload compressed image
    final ref = FirebaseStorage.instance.ref('$dir/$fileName.jpg');
    await ref.putFile(compressedImage);
    final imageUrl = await ref.getDownloadURL();

    return imageUrl;
  } catch (e) {
    print('Image upload failed: $e');
    return null;
  }
}

Future<File?> compressImage(File file, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final targetPath = path.join(tempDir.path, '$fileName.jpg');

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70,
    minWidth: 800,
    minHeight: 800,
  );

  // convert Xfile to FIle
  final newResult = File(result!.path);

  return newResult;
}
