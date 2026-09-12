import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();


  static Future<File?> pickImageWithOptions(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalization.tr.selectImageSourceTitle,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library,),
                title: Text(
                  AppLocalization.tr.chooseFromGalleryOption,

                ),
                onTap: () async {
                  final file = await _pickFromGallery();
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, ),
                title: Text(
                  AppLocalization.tr.takeAPhotoOption,

                ),
                onTap: () async {
                  final file = await _pickFromCamera();
                  Navigator.of(context).pop(file);


                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pick image from gallery
  static Future<File?> _pickFromGallery() async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);
    return xFile != null ? File(xFile.path) : null;
  }

  /// Pick image from camera and compress it
  static Future<File?> _pickFromCamera() async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.camera);
    if (xFile == null) return null;

    // Compress the camera image to reduce file size
    return await _compressImage(File(xFile.path));
  }

  /// Compress image to reduce file size
  /// This is especially important for camera photos which are typically very large
  static Future<File> _compressImage(File file) async {
    try {
      // Read the image file
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        // If decoding fails, return original file
        return file;
      }

      // Calculate new dimensions while maintaining aspect ratio
      // Max dimension set to 1920px (suitable for most use cases)
      const int maxDimension = 1920;
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          newWidth = maxDimension;
          newHeight = (image.height * maxDimension / image.width).round();
        } else {
          newHeight = maxDimension;
          newWidth = (image.width * maxDimension / image.height).round();
        }
      }

      // Resize image if needed
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode with reduced quality (85% provides good balance)
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedFile = File('${tempDir.path}/compressed_$timestamp.jpg');

      // Write compressed bytes to new file
      await compressedFile.writeAsBytes(compressedBytes);

      // Log compression results
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final reduction = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);

      print('📸 Image compressed:');
      print('   Original: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('   Compressed: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('   Reduction: $reduction%');

      return compressedFile;
    } catch (e) {
      print('❌ Error compressing image: $e');
      // Return original file if compression fails
      return file;
    }
  }

  static Future<File?> pickFromGallery() => _pickFromGallery();

  static Future<File?> pickFromCamera() => _pickFromCamera();
}
