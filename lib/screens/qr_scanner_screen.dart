import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/update_model.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller?.scannedDataStream.listen((scanData) async {
      // Pausar la cámara para evitar múltiples lecturas
      controller?.pauseCamera();

      // Mostrar el diálogo de carga
      showLoadingDialog();

      try {
        // Decodificar el JSON del QR
        final scannedData = jsonDecode(scanData.code!);
        final dynamic jsonData = {
          'codigo': scannedData['IdColumn'],
          'Nombres': scannedData['Nombres'],
          'Apellidos': scannedData['Apellidos'],
          'Correo': scannedData['Correo electrónico'],
        };

        final UpdateModel dataCompleta = UpdateModel.fromJson(jsonData);

        if (scannedData['IdColumn'] != null) {
          final result = await sendScannedData(dataCompleta);
          List<String> parts = result.split('|');
          if (parts.length < 2) return;

          String code = parts[0]; 
          String message = parts.sublist(1).join('|');

          // Cerrar el diálogo de carga antes de mostrar el resultado
          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: getColor(code),
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Resultado',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller?.resumeCamera(); // Reanudar la cámara después de cerrar el diálogo
                        },
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          throw Exception('El QR no contiene un "IdColumn" válido');
        }
      } catch (e) {
        // Cerrar el diálogo de carga en caso de error
        Navigator.pop(context);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('El QR no es válido o ocurrió un error: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller?.resumeCamera();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  // Función para mostrar la animación de carga
  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que el usuario cierre el diálogo manualmente
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Procesando...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> sendScannedData(UpdateModel data) async {
    try {
      final dynamic response = await ApiService(baseUrl: 'https://concert-webapi.abexacloud.com').fetchUser(data);
      return response.success ? response.message : response.error;
    } catch (error) {
      debugPrint('Error: $error');
      return 'Error al procesar el QR';
    }
  }

  Color getColor(String code) {
    switch (code) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.amber;
      case '3':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: QRView(
            key: qrKey,
            onQRViewCreated: onQRViewCreated,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller?.resumeCamera();
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
