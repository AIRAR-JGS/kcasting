import 'dart:io';

import 'package:flutter/cupertino.dart';

class EducationListModel {
  String _educationType;
  TextEditingController _educationName;
  TextEditingController _majorName;

  //String diplomaUrl;

  EducationListModel(this._educationType, this._educationName, this._majorName);

  String get educationType => _educationType;

  TextEditingController get majorName => _majorName;

  TextEditingController get educationName => _educationName;

  set majorName(TextEditingController value) {
    _majorName = value;
  }

  set educationName(TextEditingController value) {
    _educationName = value;
  }

  set educationType(String value) {
    _educationType = value;
  }
}
