import 'dart:io';

import 'dart:typed_data';

class VideoListModel {
  bool _isFile;
  bool _isSelected = false;
  File _videoFile;
  File _thumbnailFile;
  Map<String, dynamic> _videoData;

  VideoListModel(this._isFile, this._isSelected, this._videoFile,
      this._thumbnailFile, this._videoData);

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
}
