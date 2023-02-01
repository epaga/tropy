import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {
  String title;
  String content;
  VoidCallback continueCallBack;
  bool justMsg;

  BlurryDialog(this.title, this.content, this.continueCallBack, this.justMsg);
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: Text(
            title,
            style: textStyle,
          ),
          content: Text(
            content,
            style: textStyle,
          ),
          actions: justMsg
              ? <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      continueCallBack();
                    },
                  ),
                ]
              : <Widget>[
                  TextButton(
                    child: Text("Continue"),
                    onPressed: () {
                      continueCallBack();
                    },
                  ),
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
        ));
  }
}
