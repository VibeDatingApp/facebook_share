import 'dart:async';

import 'package:flutter/services.dart';

class FacebookShare {
  static String pageId = "000000000000000";
  static const MethodChannel _channel = const MethodChannel('facebook_share');

  static Future<bool> shareContent({String url = "", String quote = ""}) async {
    final bool succeeded = await _channel.invokeMethod('shareContent', {"url": url, "quote": quote});
    return succeeded;
  }

  static Future<bool> sendMessage({String urlActionTitle = "", String url = "", String title = "", String subtitle = "", String imageUrl = ""}) async {
    final bool succeeded = await _channel.invokeMethod('sendMessage', {
      "urlActionTitle": urlActionTitle,
      "url": url,
      "title": title,
      "subtitle": subtitle,
      "imageUrl": imageUrl,
      "pageId": pageId,
    });

    return succeeded;
  }
}
