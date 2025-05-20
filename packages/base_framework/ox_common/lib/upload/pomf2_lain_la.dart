import 'package:dio/dio.dart';
import 'base64.dart';
import 'package:http_parser/src/media_type.dart';

import 'nostr_build_uploader.dart';
import 'uploader.dart';

class Pomf2LainLa {
  static final String UPLOAD_ACTION = "https://pomf2.lain.la/upload.php";

  static Future<String?> upload(String filePath, {
    String? fileName,
    Function(double progress)? onProgress,
  }) async {
    // final dio = Dio();
    // dio.interceptors.add(PrettyDioLogger(requestBody: true));
    var fileType = Uploader.getFileType(filePath);
    MultipartFile? multipartFile;
    if (BASE64.check(filePath)) {
      var bytes = BASE64.toData(filePath);
      multipartFile = await MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: MediaType.parse(fileType),
      );
    } else {
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: MediaType.parse(fileType),
      );
    }

    var formData = FormData.fromMap({"files[]": multipartFile});
    try{
      var response =
      await NostrBuildUploader.dio.post(
        UPLOAD_ACTION,
        data: formData,
        onSendProgress: (count, total) {
          onProgress?.call(count / total);
        },
      );
      var body = response.data;
      if (body is Map<String, dynamic>) {
        return body["files"][0]["url"];
      }
    }catch(e){
      rethrow;
    }
    return null;
  }
}
