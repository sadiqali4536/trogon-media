import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnection extends StatefulWidget {
  final Widget child;

  const InternetConnection({super.key, required this.child});

  @override
  State<InternetConnection> createState() => _InternetConnectionState();
}

class _InternetConnectionState extends State<InternetConnection> {
  bool hasConnection = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasConnection = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      hasConnection = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasConnection) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
              SizedBox(height: 10),
              Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
