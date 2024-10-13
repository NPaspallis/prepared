import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

///A widget that shows a message for a sender (current user).
class Bubble extends StatelessWidget {

  final BubbleType bubbleType;
  final String avatarImageURL;
  final String name;
  final String messageText;

  const Bubble(this.bubbleType, this.avatarImageURL, this.name, this.messageText, {super.key});

  bool isSendType() => bubbleType == BubbleType.sendBubble;
  bool isReceiveType() => bubbleType == BubbleType.receiverBubble;

  Widget createCircleAvatar() {

    //Internet/Cache
    if (avatarImageURL.startsWith("http")) {
      return CachedNetworkImage(
        imageUrl: avatarImageURL,
        imageBuilder: (context, imageProvider) {
          return CircleAvatar(
            maxRadius: 32,
            backgroundImage: imageProvider,
          );
        },
      );
    }
    //Assets:
    else {
      return CircleAvatar(
        maxRadius: 32,
        backgroundImage: AssetImage(avatarImageURL),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      // color: isSendType() ? Colors.grey[300] : Colors.grey[200], //A bit confusing as there is whitespace at the end in some cases.
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          crossAxisAlignment: isSendType() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: createCircleAvatar()
            ),

            Padding(
              padding: isSendType() ? const EdgeInsets.only(right: 64, left: 8) : const EdgeInsets.only(right: 8, left: 64),
              child: ChatBubble(
                  clipper: ChatBubbleClipper1(type: bubbleType),
                  backGroundColor: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        crossAxisAlignment: isSendType() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          Container(height: 12),
                          Text(messageText, style: const TextStyle(color: Colors.black), textAlign: isSendType() ? TextAlign.start : TextAlign.end,),
                        ],
                      )
                  )
              ),
            ),
          ],
        ),
      ),
    );


  }
}
