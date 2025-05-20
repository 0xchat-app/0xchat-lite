import 'package:chatcore/chat-core.dart';

import '../enum/moment_enum.dart';
import '../utils/discovery_utils.dart';
import '../utils/moment_content_analyze_utils.dart';

class NotedUIModel {
  NoteDBISAR noteDB;
  late Map<String, UserDBISAR?> getUserInfoMap;
  late List<String> getQuoteUrlList;
  late List<String> getNddrlList;
  late List<String> getImageList;
  late List<String> getVideoList;
  late List<String> getMomentExternalLink;
  late String getMomentShowContent;
  late List<String> getMomentHashTagList;
  late String createAtStr;
  late String getMomentPlainText;
  late List<String> getLightningInvoiceList;
  late List<String> getEcashList;

  NotedUIModel({required this.noteDB}){
    loadInitialData(noteDB);
  }

  Future<void> loadInitialData(NoteDBISAR noteDB) async {
    MomentContentAnalyzeUtils analyzer = MomentContentAnalyzeUtils(noteDB.content);
    // getUserInfoMap = await mediaAnalyzer.getUserInfoMap;
    getQuoteUrlList = analyzer.getQuoteUrlList;
    getNddrlList = analyzer.getNddrlList;
    getImageList = analyzer.getMediaList(1);
    getVideoList = analyzer.getMediaList(2);
    getMomentExternalLink = analyzer.getMomentExternalLink;
    getMomentShowContent = analyzer.getMomentShowContent;
    getMomentHashTagList = analyzer.getMomentHashTagList;
    getMomentPlainText = analyzer.getMomentPlainText;
    getLightningInvoiceList = analyzer.getLightningInvoiceList;
    getEcashList = analyzer.getEcashList;
    createAtStr = DiscoveryUtils.formatTimeAgo(noteDB.createAt);
  }
}
