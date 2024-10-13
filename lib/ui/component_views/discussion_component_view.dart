import 'package:app/model/story_progress.dart';
import 'package:app/schema/discussion_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../schema/component/discussion_component.dart';
import '../../util/pref_utils.dart';
import '../widgets/bubble.dart';

/// A component that allows the user to view a discussion taking place between
/// two individuals.
class DiscussionComponentView extends StatefulWidget {

  final String storyId;
  final DiscussionComponent component;

  const DiscussionComponentView(this.storyId, this.component, {super.key});

  @override
  State<DiscussionComponentView> createState() => _DiscussionComponentViewState();
}

class _DiscussionComponentViewState extends State<DiscussionComponentView> {

  late int _currentMessageIndex = 0;

  List<DiscussionMessage> shownMessages = [];

  bool alreadyCompleted = false;

  String _getKeyCurrentIndex() {
    return '${PreferenceUtils.keyCurrentDiscussionIndex}-${widget.storyId}-${widget.component.id}';
  }

  late String _p1Name;
  late String _p1ImageUrl;
  late String _p2Name;
  late String _p2ImageUrl;

  @override
  void initState() {
    super.initState();
    _p1Name = widget.component.participants[0].name;
    _p1ImageUrl = widget.component.participants[0].image;
    _p2Name = widget.component.participants[1].name;
    _p2ImageUrl = widget.component.participants[1].image;

    alreadyCompleted = Provider.of<StoryProgress>(context, listen: false).isCompleted(widget.storyId, widget.component.id);

    // restore current index
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _currentMessageIndex = prefs.getInt(_getKeyCurrentIndex()) ?? 1;
        _checkIfCompleted();
      });
    });

  }

  @override
  void dispose() {
    // save current index
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_getKeyCurrentIndex(), _currentMessageIndex);
    });
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> messages = [];

    //Show all messages up to the current message index.
    for(int i = 0; i < _currentMessageIndex; i++) {
      int senderIndex = widget.component.messages[i].senderIndex;
      String message = widget.component.messages[i].text;
      if(senderIndex == 0) {
        messages.add(Bubble(BubbleType.sendBubble, _p1ImageUrl, _p1Name, message));
      } else {
        messages.add(Bubble(BubbleType.receiverBubble, _p2ImageUrl, _p2Name, message));
      }
    }
    _scrollToEnd();

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: messages
          )
        ),
        const Divider(height: 1, color: Colors.grey),
        Container(
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(  
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: _currentMessageIndex > 1 ? _previousMessage : null,
                    child: const Icon(Icons.navigate_before)),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                    onPressed: _currentMessageIndex < widget.component.messages.length ? _nextMessage : null,
                    child: const Icon(Icons.navigate_next)),
              ),
            ],
          ),
        )
      ]
    );
  }

  void _previousMessage() {
    setState(() {
      if(_currentMessageIndex > 0) {
        _currentMessageIndex--;
      }
    });
    _scrollToEnd();
  }

  void _nextMessage() {
    setState(() {
      if(_currentMessageIndex < widget.component.messages.length) {
        _currentMessageIndex++;
        _checkIfCompleted();
      }
    });
    _scrollToEnd();
  }

  void _checkIfCompleted() {
    bool completed = _currentMessageIndex == widget.component.messages.length || alreadyCompleted;
    Provider.of<StoryProgress>(context, listen: false).setCompleted(
        widget.storyId, widget.component.id, completed);
  }

  _scrollToEnd() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn);
    });
  }
}