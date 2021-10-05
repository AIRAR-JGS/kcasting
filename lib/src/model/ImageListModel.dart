import 'dart:io';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImageListModel {
  bool _isFile;
  bool _isSelected = false;
  File _photoFile;
  Map<String, dynamic> _photoData;
  Uint8List _bytesData;
  MultipartFile _multipartFile;

  ImageListModel(
      this._isFile, this._isSelected, this._photoFile, this._photoData, this._bytesData, this._multipartFile);

  Map<String, dynamic> get photoData => _photoData;

  File get photoFile => _photoFile;

  bool get isSelected => _isSelected;

  bool get isFile => _isFile;

  Uint8List get bytesData => _bytesData;

  MultipartFile get multipartFile => _multipartFile;

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

  set bytesData(Uint8List value) {
    _bytesData = value;
  }

  set multipartFile(MultipartFile value) {
    _multipartFile = value;
  }
}
