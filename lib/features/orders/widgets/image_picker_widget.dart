import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImageSelected;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImage,
    required this.onImageSelected,
  }) : super(key: key);

  Future<void> _selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      onImageSelected(File(pickedImage.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              )
            : const Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.black54,
                ),
              ),
      ),
    );
  }
}
