import 'dart:ui';
import 'data.dart';
import 'package:flutter/material.dart';

class BlurryDialog extends StatefulWidget {
  final String title;
  final String content;
  final VoidCallback continueCallBack;
  final bool justMsg;
  final bool showForm;

  const BlurryDialog(this.title, this.content, this.continueCallBack,
      this.justMsg, this.showForm,
      {super.key});

  @override
  State<BlurryDialog> createState() => _BlurryDialogState();
}

class _BlurryDialogState extends State<BlurryDialog> {
  final _formKey = GlobalKey<FormState>();
  _BlurryDialogState();
  TextStyle textStyle = const TextStyle(color: Colors.black);
  final _privStyle = const TextStyle(color: Colors.grey, fontSize: 10);
  final _nameFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _countryFocus = FocusNode();
  final _emailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Widget cWidget = Text(
      widget.content,
      style: textStyle,
    );
    if (widget.showForm && !widget.justMsg) {
      cWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  focusNode: _nameFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_cityFocus);
                  },
                  onSaved: (newValue) => {Data.submission.name = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateNotEmpty(value, _nameFocus),
                  decoration: const InputDecoration(
                    labelText: 'Real Name',
                    icon: Icon(Icons.account_box),
                  ),
                ),
                TextFormField(
                  focusNode: _cityFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_codeFocus);
                  },
                  onSaved: (newValue) =>
                      {Data.submission.cityState = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateNotEmpty(value, _cityFocus),
                  decoration: const InputDecoration(
                    labelText: 'City, State',
                    icon: Icon(Icons.location_city),
                  ),
                ),
                TextFormField(
                  focusNode: _codeFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_countryFocus);
                  },
                  onSaved: (newValue) => {Data.submission.postal = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateNotEmpty(value, _codeFocus),
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    icon: Icon(Icons.numbers),
                  ),
                ),
                TextFormField(
                  focusNode: _countryFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                  onSaved: (newValue) => {Data.submission.country = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateNotEmpty(value, _countryFocus),
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    icon: Icon(Icons.map),
                  ),
                ),
                TextFormField(
                  focusNode: _emailFocus,
                  onSaved: (newValue) => {Data.submission.email = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateNotEmpty(value, _emailFocus),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Note: Your data will not be passed on to any third party, it will only be used for keeping track of your contest entry!",
                    style: _privStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: Text(
            widget.title,
            style: textStyle,
          ),
          content: cWidget,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: widget.justMsg
              ? <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      widget.continueCallBack();
                    },
                  ),
                ]
              : <Widget>[
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        widget.continueCallBack();
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text("Submit"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Not Yet"),
                  ),
                ],
        ));
  }

  String? validateNotEmpty(String? value, FocusNode focus) {
    if (value == null || value.length < 5) {
      focus.requestFocus();
      return 'Value required here.';
    } else {
      return null;
    }
  }
}
