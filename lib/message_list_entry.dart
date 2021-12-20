import 'package:flutter/material.dart';
class MessageListEntry extends Container { MessageListEntry(
    @required String who,
    @required String message,
    @required bool me
    ) : super(
  padding: const EdgeInsets.all(8),
  child: Row(
      children: [
  Expanded(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start, children: [
  Container(
  padding: const EdgeInsets.only(bottom: 8), child: Text(
  who,
  style: TextStyle(
    fontWeight: FontWeight.bold, ),
), ),
      Container(
          child: Text(
          message,
          style: TextStyle(
          color: Colors.grey[500],
      ), ),
), ],
), ),
],
mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
), );
}