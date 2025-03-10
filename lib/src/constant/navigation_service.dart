// ignore_for_file: file_names

import 'package:flutter/material.dart';

abstract class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final BuildContext? _context = navigatorKey.currentContext;

  static pushReplacementNamed(String path) {
    if (_context != null) {
      Navigator.of(_context!).pushReplacementNamed(path);
    }
  }

  static pushNamed(String path) {
    if (_context != null) {
      Navigator.of(_context!).pushNamed(path);
    }
  }

  static pop(String path) {
    if (_context != null) {
      Navigator.of(_context!).pop(path);
    }
  }
}
