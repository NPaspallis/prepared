import 'dart:io';

extension PlatformExtension on Platform {
  String get lineSeparator => Platform.isWindows || Platform.isAndroid
      ? '\r\n'
      : Platform.isMacOS || Platform.isIOS
      ? '\r'
      : Platform.isLinux
      ? '\n'
      : '\n';
}