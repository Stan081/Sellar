import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sellar/src/constants/app_constants.dart';
import 'package:sellar/src/services/api_service.dart';

class UploadRepository {
  final ApiService apiService;

  UploadRepository({required this.apiService});

  Future<String> uploadImage(File file) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await apiService.post(
      AppConstants.uploadImagePath,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data['url'] as String;
  }
}
