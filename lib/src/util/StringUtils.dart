class StringUtils {
  static bool isEmpty(var str) {

    if(str == null)
      return true;

    String _str = str.toString().trim();

    if (_str == null || _str.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static String trimmedString(var str) {
    return str.toString().trim();
  }

  static String checkedString(var str) {
    String _str = str.toString();

    return (_str != null ? (_str == "null" ? "-" : _str) : "-");
  }
}
