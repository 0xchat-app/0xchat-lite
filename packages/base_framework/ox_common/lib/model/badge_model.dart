import 'dart:async';
import 'dart:convert';

import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';

///Title: badge_model
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2023/5/6 15:09
class BadgeModel {
  final String? badgeName;

  final String? badgeImageUrl;

  final String? badgeId;

  final String? identifies;

  final String? description;

  final String? thumbUrl;

  final String? localImage;

  final String? creator;

  final int? createTime;

  int? obtainedTime;

  final String? creatorAbout;

  final String? howToGet;

  final List<String>? benefits;

  final List<String>? benefitsIcon;

  BadgeModel({
    this.badgeId = '',
    this.badgeName = '',
    this.badgeImageUrl = '',
    this.identifies = '',
    this.description = '',
    this.thumbUrl = '',
    this.localImage,
    this.creator = '',
    this.createTime,
    this.obtainedTime,
    this.creatorAbout,
    this.howToGet,
    this.benefits,
    this.benefitsIcon,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    List<String> benefitList = [];
    List<String> benefitIconList = [];

    if (json['benefits'] != null) {
      json['benefits'].forEach((value) {
        benefitList.add(value);
      });
    }

    if (json['benefitsIcon'] != null) {
      json['benefitsIcon'].forEach((value) {
        benefitIconList.add(value);
      });
    }

    return BadgeModel(
      badgeId: json['badgeId'] ?? '',
      badgeName: json['badgeName'] ?? '',
      badgeImageUrl: json['badgeImageUrl'] ?? '',
      identifies: json['identifies'] ?? '',
      description: json['description'] ?? '',
      thumbUrl: json['thumbUrl'] ?? '',
      creator: json['creator'] ?? '',
      creatorAbout: json['creatorAbout'] ?? '',
      howToGet: json['howToGet'] ?? '',
      benefits: benefitList,
      benefitsIcon: benefitIconList,
    );
  }

  factory BadgeModel.fromBadgeDB(BadgeDBISAR badgeDB) {
    return BadgeModel(
        badgeId: badgeDB.badgeID,
        badgeName: badgeDB.name,
        badgeImageUrl: badgeDB.image,
        identifies: badgeDB.d,
        description: badgeDB.description,
        thumbUrl: badgeDB.thumb,
        creator: badgeDB.creator,
        createTime: badgeDB.createTime);
  }

  @override
  String toString() {
    return 'BadgeModel{badgeName: $badgeName, badgeImageUrl: $badgeImageUrl, badgeId: $badgeId, identifies: $identifies, description: $description, thumbUrl: $thumbUrl, localImage: $localImage, creator: $creator, createTime: $createTime, obtainedTime: $obtainedTime},creatorAbout: $creatorAbout';
  }

  static Future<List<BadgeModel>> getDefaultBadge({BuildContext? context, bool? showLoading}) async {
    List<BadgeModel> defaultBadgeModelList = [];

    Map<String, dynamic> result = json.decode(BadgesHelper.sharedInstance.defaultBadgesString);
    if (result['code'] == "000000") {
      List<dynamic> badgeMapList = result['data'];
      defaultBadgeModelList = badgeMapList.map((value) => BadgeModel.fromJson(value)).toList();
    }
    return defaultBadgeModelList;
  }
}
