import 'dart:io';

import 'dart:typed_data';

import 'package:dio/dio.dart';

class VideoListModel {
  bool _isFile;
  bool _isSelected = false;
  File _videoFile;
  File _thumbnailFile;
  Map<String, dynamic> _videoData;
  MultipartFile _multipartFile;
  String _thumbnailUrl;

  VideoListModel(this._isFile, this._isSelected, this._videoFile,
      this._thumbnailFile, this._videoData,this._multipartFile, this._thumbnailUrl);

  Map<String, dynamic> get videoData => _videoData;

  set videoData(Map<String, dynamic> value) {
    _videoData = value;
  }

  File get thumbnailFile => _thumbnailFile;

  set thumbnailFile(File value) {
    _thumbnailFile = value;
  }

  File get videoFile => _videoFile;

  set videoFile(File value) {
    _videoFile = value;
  }

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    _isSelected = value;
  }

  bool get isFile => _isFile;

  set isFile(bool value) {
    _isFile = value;
  }

  String get thumbnailUrl => _thumbnailUrl;

  set thumbnailUrl(String value) {
    _thumbnailUrl = value;
  }

  MultipartFile get multipartFile => _multipartFile;

  set multipartFile(MultipartFile value) {
    _multipartFile = value;
  }
}
