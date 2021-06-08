import 'dart:io';

import 'package:flutter/cupertino.dart';

class CheckboxItemModel {
  String _itemName;
  bool _isSelected = false;

  CheckboxItemModel(this._itemName, this._isSelected);

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    _isSelected = value;
  }

  String get itemName => _itemName;

  set itemName(String value) {
    _itemName = value;
  }
}
