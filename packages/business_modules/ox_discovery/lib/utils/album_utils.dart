import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/utils/file_utils.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:path/path.dart' as Path;
import 'package:ox_common/utils/image_picker_utils.dart';

class AlbumUtils {
  // 1 image 2 video
  static Future<void> openAlbum(BuildContext context,
      {int type = 1,
      int selectCount = 9,
      Function(List<String>)? callback}) async {
    final isVideo = type == 2;
    List<Media> mediaList = [];
    if(PlatformUtils.isDesktop){
      List<Media>? list = await FileUtils.importClientFile(type);
      if(list != null) mediaList = list;
    }else{
      mediaList = await ImagePickerUtils.pickerPaths(
        galleryMode: isVideo ? GalleryMode.video : GalleryMode.image,
        selectCount: selectCount,
        showGif: false,
        compressSize: 1024,
      );
    }

    if(mediaList.isEmpty) return;

    if (isVideo) {
      dealWithVideo(context, mediaList, callback);
    } else {
      List<File> fileList = [];
      await Future.forEach(mediaList, (element) async {
        final entity = element;
        final file = File(entity.path ?? '');
        fileList.add(file);
      });
      dealWithPicture(context, fileList, callback);
    }
  }

  static Future<void> openCamera(
      BuildContext context, Function(List<String>)? callback) async {
    Media? res = await ImagePickerUtils.openCamera(
      cameraMimeType: CameraMimeType.photo,
      compressSize: 1024,
    );
    if (res == null) return;
    final file = File(res.path ?? '');
    dealWithPicture(context, [file], callback);
  }

  static Future dealWithPicture(
    BuildContext context,
    List<File> images,
    Function(List<String>)? callback,
  ) async {
    List<String> imageList = [];
    for (final result in images) {
      String fileName = Path.basename(result.path);
      fileName = fileName.substring(13);
      imageList.add(result.path.toString());
    }
    callback?.call(imageList);
  }

  static Future dealWithVideo(BuildContext context, List<Media> mediaList,
      Function(List<String>)? callback) async {
    for (final media in mediaList) {
      callback?.call([media.path ?? '', media.thumbPath ?? '']);
    }
  }

  static Future<List<String>> uploadMultipleFiles(
    BuildContext? context, {
    required List<String> filePathList,
    required FileType fileType,
    bool showLoading = true
  }) async {
    List<String> uploadedUrls = [];

    for (String filePath in filePathList) {
      final currentTime = DateTime.now().microsecondsSinceEpoch.toString();
      String fileName = '$currentTime${Path.basenameWithoutExtension(filePath)}.${fileType == FileType.image ? 'jpg' : 'mp4'}';
      File imageFile = File(filePath);
      UploadResult result = await UploadUtils.uploadFile(
        context: context,
        fileType: fileType,
        file: imageFile,
        filename: fileName,
        showLoading: showLoading
      );
      if (result.isSuccess && result.url.isNotEmpty) {
        uploadedUrls.add(result.url);
      } else {
        CommonToast.instance.show(context, result.errorMsg ?? 'Upload Failed');
      }
    }
    return uploadedUrls;
  }
}
