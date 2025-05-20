
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ox_common/const/common_constant.dart';
import 'package:ox_common/log_util.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:dio/dio.dart';
import 'package:ox_common/network/network_general.dart';
import 'package:ox_common/utils/aes_encrypt_utils.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_network/network_manager.dart';

enum UplodAliyunType {
  imageType,
  voiceType,
  videoType,
  logType,
}

class UplodAliyun {

  static bool isAliOSSUrl(String url) =>
      url.startsWith('https://${CommonConstant.ossBucketName}.${CommonConstant.ossEndPoint}');

  static Future<String> uploadFileToAliyun({
    BuildContext? context,
    params,
    required UplodAliyunType fileType,
    required File file,
    required String filename,
    bool showLoading = true,
    Function(double progress)? onProgress,
  }) async {
    return OXNetwork.instance
        .doRequest(
      context,
      url: 'https://www.0xchat.com/nostrchat/oss/getSts',
      showErrorToast: true,
      needCommonParams: false,
      needRSA: false,
      type: RequestType.GET,
    ).then((OXResponse response) async {
      if(showLoading) OXLoading.show();
      Map<String, dynamic> dataMap = Map<String, dynamic>.from(response.data);
      // LogUtil.e("upload : ${response}");
      // LogUtil.e('upload : ${dataMap}');
      Client.init(
        ossEndpoint: CommonConstant.ossEndPoint,
        bucketName: CommonConstant.ossBucketName,
        authGetter: () => _authGetter(authMap: dataMap),
      );
      String uri = await uploadFile(
        filepath: file.path,
        fileType: fileType,
        filename: filename,
        onProgress: onProgress,
      );
      if(showLoading) OXLoading.dismiss();
      return uri;
      // return false;
    }).catchError((e) {
      LogUtil.e("what:$e");
      return '';
    });
  }

  static Auth _authGetter({required Map<String, dynamic> authMap}) {
    String secureToken = AesEncryptUtils.aes128Decrypt(authMap['encryptStsToken']);
    LogUtil.e("secureToken : $secureToken");
    return Auth(
      accessKey: authMap['accessKeyId'],
      accessSecret: authMap['accessKeySecret'],
      expire: authMap['expiration'],
      secureToken: secureToken,
    );
  }

  static Future<String> uploadFile({
    required String filepath,
    required UplodAliyunType fileType,
    required String filename,
    Function(double progress)? onProgress,
  }) async {
    String fileFolder = getFileFolders(fileType);
    Response<dynamic> resp = await Client().putObjectFile(
      filepath,
      option: PutRequestOption(
        onSendProgress: (count, total) {
          onProgress?.call(count / total);
        },
        onReceiveProgress: (count, total) {
          // print("receive: count = $count, and total = $total");
        },
        override: true,
        aclModel: AclMode.publicRead,
        callback: Callback(
          callbackUrl: "https://www.0xchat.com/nostrchat/oss/callback",
          callbackBody: "{\"mimeType\":\${mimeType}, \"filepath\":\${object},\"size\":\${size},\"bucket\":\${bucket},\"phone\":\${x:phone}}",
          calbackBodyType: CalbackBodyType.json,
        ),
      ),
      fileKey: "$fileFolder$filename",
    );
    LogUtil.e("resp : $resp");

    String uri = 'https://${CommonConstant.ossBucketName}.${CommonConstant.ossEndPoint}/$fileFolder$filename';
    return uri;
  }

  static String getFileFolders(UplodAliyunType fileType) {
    switch(fileType){
      case UplodAliyunType.imageType:
        return 'images/';
      case UplodAliyunType.videoType:
        return 'video/';
      case UplodAliyunType.voiceType:
        return 'voice/';
      case UplodAliyunType.logType:
        return 'logs/';
    }
  }

  // https://help.aliyun.com/zh/oss/user-guide/video-snapshots
  static String getSnapshot(
      String url,
      {String t = '0',
        String f = 'jpg',
        String w = '0',
        String h = '0',
        String m = 'fast',
        String ar = 'auto',
      }) {

    final aliyunSnapshotParams = {
      'spm': 'qipa250',
      'x-oss-process': 'video/snapshot,t_$t,f_$f,w_$w,h_$h,m_$m,ar_$ar',
    };

    final uri = Uri.tryParse(url);
    if (uri == null) {
      final queryString = aliyunSnapshotParams.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('&');
      return '$url?$queryString';
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...aliyunSnapshotParams,
      },
    ).toString();
  }
}
