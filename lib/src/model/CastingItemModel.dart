import 'dart:io';

import 'dart:typed_data';

class CastingItemModel {

  bool _isSelected = false;
  int _castingSeq;
  String _projectName;
  String _castingName;
  int _isAlreadyProposal;

  CastingItemModel(this._isSelected, this._castingSeq, this._projectName,
      this._castingName, this._isAlreadyProposal);

  int get isAlreadyProposal => _isAlreadyProposal;

  set isAlreadyProposal(int value) {
    _isAlreadyProposal = value;
  }

  String get castingName => _castingName;

  set castingName(String value) {
    _castingName = value;
  }

  String get projectName => _projectName;

  set projectName(String value) {
    _projectName = value;
  }

  int get castingSeq => _castingSeq;

  set castingSeq(int value) {
    _castingSeq = value;
  }

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    _isSelected = value;
  }
}