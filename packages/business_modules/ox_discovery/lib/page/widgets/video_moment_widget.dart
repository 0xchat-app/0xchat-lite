import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/video_data_manager.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_video_page.dart';
import '../../utils/moment_widgets_utils.dart';

class VideoMomentWidget extends StatefulWidget {
  final String videoUrl;

  const VideoMomentWidget({super.key, required this.videoUrl});

  @override
  _VideoMomentWidgetState createState() => _VideoMomentWidgetState();
}

class _VideoMomentWidgetState extends State<VideoMomentWidget> {
  File? _thumbnailFile;

  @override
  void initState() {
    super.initState();
    _initializeThumbnail();
  }

  Future<void> _initializeThumbnail() async {
    final media = await VideoDataManager.shared.fetchVideoMedia(videoURL:  widget.videoUrl);
    final String? thumbPath = media?.thumbPath;
    if (mounted) {
      setState(() {
        if (thumbPath != null && thumbPath.isNotEmpty) {
          _thumbnailFile = File(thumbPath);
        }
      });
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoUrl != oldWidget.videoUrl) {
      if (mounted) {
        _thumbnailFile = null;
      }
      _initializeThumbnail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return videoMoment();
  }

  Widget videoMoment() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10.px,
      ),
      child: GestureDetector(
        onTap: () {
          CommonVideoPage.show(widget.videoUrl);
        },
        child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: ThemeColor.color100,
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      Adapt.px(12),
                    ),
                  ),
                ),
                width: 210.px,
                // height: 154.px,
              ),
              _getPicWidget(),
              // _videoSurfaceDrawingWidget(),
              CommonImage(
                iconName: 'play_moment_icon.png',
                package: 'ox_discovery',
                size: 60.0.px,
                color: Colors.white,
              )
            ],
          ),

      ),
    );
  }

  Widget _getPicWidget() {
    if (_thumbnailFile == null) return const SizedBox();
    return MomentWidgetsUtils.clipImage(
      borderRadius: 8.px,
      child: Image.file(
        _thumbnailFile!,
        width: 210.px,
        fit: BoxFit.cover,
      ),
    );
  }
}
