import 'package:flutter/material.dart';
import 'package:ox_common/mixin/common_state_view_mixin.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:chatcore/chat-core.dart';

class SearchNoteView extends StatefulWidget {
  final String searchQuery;

  const SearchNoteView({super.key, required this.searchQuery});

  @override
  State<SearchNoteView> createState() => _SearchNoteViewState();
}

class _SearchNoteViewState extends State<SearchNoteView>
    with CommonStateViewMixin {

  List<NoteDBISAR> _notes = [];

  @override
  void initState() {
    super.initState();
    if (_notes.isEmpty) {
      updateStateView(CommonStateView.CommonStateView_NoData);
    }
  }

  @override
  stateViewCallBack(CommonStateView commonStateView) {
    switch (commonStateView) {
      case CommonStateView.CommonStateView_None:
        break;
      case CommonStateView.CommonStateView_NetworkError:
      case CommonStateView.CommonStateView_NoData:
        break;
      case CommonStateView.CommonStateView_NotLogin:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonStateViewWidget(
      context,
      ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.px),
        itemBuilder: (context, index) => _buildNoteWidget(_notes[index]),
        itemCount: _notes.length,
      ),
    );
  }

  Widget _buildNoteWidget(NoteDBISAR noteDB) {
    return OXModuleService.invoke(
      'ox_discovery',
      'momentWidget',
      [context],
      {
        #noteDB: noteDB,
      },
    );
  }

  void _searchNotes(String keyword) async {
    List<NoteDBISAR> noteList = await Moment.sharedInstance.searchNotesWithKeyword(keyword);
    if (noteList.isEmpty) {
      updateStateView(CommonStateView.CommonStateView_NoData);
    } else {
      _notes.addAll(noteList);
      updateStateView(CommonStateView.CommonStateView_None);
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SearchNoteView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _notes.clear();
      _searchNotes(widget.searchQuery);
    }
  }
}
