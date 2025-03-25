import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageRepository extends GetxService {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<String> uploadImageToSupabase(
      String bucketName, String ref, File file) async {
    try {
      print('Uploading file to Supabase...');

      if (!file.existsSync()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      // Supprimer le fichier s'il existe déjà
      await supabaseClient.storage.from(bucketName).remove([ref]);

      // Upload du fichier
      await supabaseClient.storage.from(bucketName).upload(ref, file);

      // Récupérer l'URL publique
      final publicUrl =
          supabaseClient.storage.from(bucketName).getPublicUrl(ref);
      print('File uploaded successfully: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('Error uploading file to Supabase: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> storeFileToSupabase(
      String bucket, String path, File file) async {
    try {
      final bytes = await file.readAsBytes();

      await supabaseClient.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getMimeType(file.path),
            ),
          );

      // Récupérer l'URL publique
      final publicUrl = supabaseClient.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }
}
