// ietnore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../feature/widgets/app_texts.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _hasConnection = true;
  bool _isSnackBarVisible = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _checkConnectivity());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      setState(() {
        _hasConnection = response.statusCode == 200;
      });
    } catch (_) {
      setState(() {
        _hasConnection = true;
      });
    }
    _showConnectivitySnackBar();
  }

  void _showConnectivitySnackBar() {
    if (!_hasConnection) {
      if (!_isSnackBarVisible) {
        _isSnackBarVisible = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
                backgroundColor: Colors.black45,
                content: const Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 7),
                    Texts(
                      texts: 'No internet connection',
                      color: Colors.white,
                    ),
                  ],
                ),
                duration: const Duration(days: 1),
              ),
            )
            .closed
            .then((_) => _isSnackBarVisible = false);
      }
    } else if (_isSnackBarVisible) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
          backgroundColor: Colors.green.shade500,
          content: const Row(
            children: [
              Icon(
                Icons.wifi,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Texts(
                texts: 'Internet connection restored',
                color: Colors.white,
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      _isSnackBarVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
