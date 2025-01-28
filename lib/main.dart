import 'package:flutter/material.dart';
import 'package:qr_scanner_app/services/api_service.dart';
import 'screens/home_screen.dart';


void main() {
  final apiService = ApiService(
    baseUrl: 'https://concert-webapi.abexacloud.com',
    ignoreBadCertificates: true
  );

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(apiService: apiService)
    );
  }
}
