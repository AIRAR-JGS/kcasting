import 'dart:io';

class ImageListModel {
  bool _isFile;
  bool _isSelected = false;
  File _photoFile;
  Map<String, dynamic> _photoData;

  ImageListModel(
      this._isFile, this._isSelected, this._photoFile, this._photoData);

  Map<String, dynamic> get photoData => _photoData;

  File get photoFile => _photoFile;

  bool get isSelected => _isSelected;

  bool get isFile => _isFile;

  set photoData(Map<String, dynamic> value) {
    _photoData = value;
  }

  set photoFile(File value) {
    _photoFile = value;
  }

  set isSelected(bool value) {
    _isSelected = value;
  }

  set isFile(bool value) {
    _isFile = value;
  }
}
