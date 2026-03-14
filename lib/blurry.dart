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
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _cityFieldKey = GlobalKey<FormFieldState<String>>();
  final _codeFieldKey = GlobalKey<FormFieldState<String>>();
  final _countryFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
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
                  key: _nameFieldKey,
                  focusNode: _nameFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_cityFocus);
                  },
                  onSaved: (newValue) => {Data.submission.name = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateNotEmpty,
                  decoration: const InputDecoration(
                    labelText: 'Real Name',
                    icon: Icon(Icons.account_box),
                  ),
                ),
                TextFormField(
                  key: _cityFieldKey,
                  focusNode: _cityFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_codeFocus);
                  },
                  onSaved: (newValue) =>
                      {Data.submission.cityState = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateNotEmpty,
                  decoration: const InputDecoration(
                    labelText: 'City, State',
                    icon: Icon(Icons.location_city),
                  ),
                ),
                TextFormField(
                  key: _codeFieldKey,
                  focusNode: _codeFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_countryFocus);
                  },
                  onSaved: (newValue) => {Data.submission.postal = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateNotEmpty,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    icon: Icon(Icons.numbers),
                  ),
                ),
                TextFormField(
                  key: _countryFieldKey,
                  focusNode: _countryFocus,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                  onSaved: (newValue) => {Data.submission.country = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateNotEmpty,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    icon: Icon(Icons.map),
                  ),
                ),
                TextFormField(
                  key: _emailFieldKey,
                  focusNode: _emailFocus,
                  onSaved: (newValue) => {Data.submission.email = newValue!},
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateNotEmpty,
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
                      } else {
                        _focusFirstInvalidField();
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

  String? validateNotEmpty(String? value) {
    if (value == null || value.trim().length < 5) {
      return 'Value required here.';
    }
    return null;
  }

  void _focusFirstInvalidField() {
    if (_nameFieldKey.currentState?.hasError ?? false) {
      _nameFocus.requestFocus();
      return;
    }
    if (_cityFieldKey.currentState?.hasError ?? false) {
      _cityFocus.requestFocus();
      return;
    }
    if (_codeFieldKey.currentState?.hasError ?? false) {
      _codeFocus.requestFocus();
      return;
    }
    if (_countryFieldKey.currentState?.hasError ?? false) {
      _countryFocus.requestFocus();
      return;
    }
    if (_emailFieldKey.currentState?.hasError ?? false) {
      _emailFocus.requestFocus();
    }
  }
}
