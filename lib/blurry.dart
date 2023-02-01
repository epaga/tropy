import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryDialog extends StatefulWidget {
  String title;
  String content;
  VoidCallback continueCallBack;
  bool justMsg;
  bool showForm;

  BlurryDialog(this.title, this.content, this.continueCallBack, this.justMsg,
      this.showForm,
      {super.key});

  @override
  State<BlurryDialog> createState() =>
      _BlurryDialogState(title, content, continueCallBack, justMsg, showForm);
}

class _BlurryDialogState extends State<BlurryDialog> {
  String title;
  String content;
  VoidCallback continueCallBack;
  bool justMsg;
  bool showForm;
  final _formKey = GlobalKey<FormState>();
  _BlurryDialogState(this.title, this.content, this.continueCallBack,
      this.justMsg, this.showForm);
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    Widget cWidget = Text(
      content,
      style: textStyle,
    );
    if (showForm && !justMsg) {
      cWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                validator: (value) =>
                    value == null || value.length < 5 ? 'Name required.' : null,
                decoration: InputDecoration(
                  labelText: 'Real Name',
                  icon: Icon(Icons.account_box),
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                validator: (value) =>
                    value == null || value.length < 3 ? 'City required.' : null,
                decoration: InputDecoration(
                  labelText: 'City, State',
                  icon: Icon(Icons.location_city),
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => value == null || value.length < 5
                    ? 'Postal Code required.'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  icon: Icon(Icons.numbers),
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => value == null || value.length < 5
                    ? 'Country required.'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Country',
                  icon: Icon(Icons.map),
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => value == null || value.length < 5
                    ? 'Email required.'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: Text(
            title,
            style: textStyle,
          ),
          content: cWidget,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
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
                    child: Text("Submit"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        continueCallBack();
                      }
                    },
                  ),
                  TextButton(
                    child: Text("Not Yet"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
        ));
  }
}
