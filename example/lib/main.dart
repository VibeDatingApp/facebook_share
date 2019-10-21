import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:facebook_share/facebook_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = 'Click to share via Facebook';

  @override
  void initState() {
    super.initState();
    FacebookShare.pageId = "631062260652829";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FlatButton(
              color: Colors.black87,
              child: Text(
                "Share",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                String message;
                bool succeeded;

                try {
                  succeeded = await FacebookShare.shareContent(url: "https://nemob.id", quote: "Dapatkan Promo");

                  if (succeeded) {
                    succeeded = await FacebookShare.sendMessage(
                        urlActionTitle: "Visit",
                        url: "https://nemob.id",
                        title: "Promotion",
                        subtitle: "Get your promotion now!",
                        imageUrl:
                        "https://d1whtlypfis84e.cloudfront.net/guides/wp-content/uploads/2018/03/10173552/download6.jpg");
                    if (succeeded) {
                      message = "Shared successfully";
                    } else {
                      message = "Failed to share";
                    }
                  } else {
                    message = "Failed to share";
                  }
                } on PlatformException catch (e) {
                  message = "${e.message}";
                }

                if (!mounted) return;

                setState(() {
                  _message = message;
                });
              },
            ),
            Text(_message),
          ]),
        ),
      ),
    );
  }
}
