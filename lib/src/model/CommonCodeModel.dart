import 'dart:io';

import 'package:flutter/cupertino.dart';

class CommonCodeModel {
  int _seq;
  String _childName;
  bool _isSelected = false;

  CommonCodeModel(this._seq, this._childName, this._isSelected);

  String get childName => _childName;

  set childName(String value) {
    _childName = value;
  }

  int get seq => _seq;

  set seq(int value) {
    _seq = value;
  }

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    _isSelected = value;
  }
}
