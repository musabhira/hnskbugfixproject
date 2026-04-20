import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

void main() async {
  SharePlus.instance.share(ShareParams(
    text: 'test',
    subject: 'sub',
    // sharePositionOrigin: Rect.fromLTWH(0,0,10,10),
  ));
}
