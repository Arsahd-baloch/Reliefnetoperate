import 'dart:io';
import 'package:dio/dio.dart';
import 'package:reliefnet_app/config/env.dart';
import 'package:reliefnet_app/core/api/api_constants.dart';

/// Uploads an image from a local file path.
/// Uses Cloudinary when credentials are configured; falls back to the backend
/// `/api/media/upload` endpoint otherwise.
Future<String> uploadImageFile(
  String filePath,
  Dio backendDio, {
  void Function(double progress)? onProgress,
}) async {
  if (Env.cloudinaryCloudName.isNotEmpty &&
      Env.cloudinaryUploadPreset.isNotEmpty) {
    final cloudinaryDio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'upload_preset': Env.cloudinaryUploadPreset,
    });
    final response = await cloudinaryDio.post(
      'https://api.cloudinary.com/v1_1/${Env.cloudinaryCloudName}/image/upload',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return response.data['secure_url'] as String;
  } else {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: File(filePath).uri.pathSegments.last,
      ),
    });
    final response = await backendDio.post(
      ApiConstants.mediaUpload,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return (response.data as Map<String, dynamic>)['url'] as String;
  }
}

/// Uploads an image from raw bytes (e.g. when only bytes are available,
/// not a file path). Same Cloudinary → backend fallback logic.
Future<String> uploadImageBytes(
  List<int> bytes,
  String filename,
  Dio backendDio, {
  void Function(double progress)? onProgress,
}) async {
  if (Env.cloudinaryCloudName.isNotEmpty &&
      Env.cloudinaryUploadPreset.isNotEmpty) {
    final cloudinaryDio = Dio();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'upload_preset': Env.cloudinaryUploadPreset,
    });
    final response = await cloudinaryDio.post(
      'https://api.cloudinary.com/v1_1/${Env.cloudinaryCloudName}/image/upload',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return response.data['secure_url'] as String;
  } else {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await backendDio.post(
      ApiConstants.mediaUpload,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return (response.data as Map<String, dynamic>)['url'] as String;
  }
}
