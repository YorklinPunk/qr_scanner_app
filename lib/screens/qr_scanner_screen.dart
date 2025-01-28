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

        // Validar que contiene los datos esperados
        if (scannedData['IdColumn'] != null) {
          final result = await sendScannedData(dataCompleta);

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Resultado'),
                content: Text(result),
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
        } else {
          throw Exception('El QR no contiene un "IdColumn" válido');
        }
      } catch (e) {
        // Manejo de errores
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


  Future<String> sendScannedData(UpdateModel data) async {
    try {
      final dynamic response = await ApiService(baseUrl: 'https://concert-webapi.abxcloud.com').fetchUser(data);
      if (response.success) {        
        return response.message; // Devuelve el mensaje del servidor
      } else {
        return response.error; // Devuelve el error del servidor
      }
    } catch (error) {
      debugPrint('Error: $error');
      return 'Error al procesar el QR';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Center(
        child: Container(
          width: 300, // Ajusta el ancho según tus necesidades
          height: 300, // Ajusta la altura según tus necesidades
          child: QRView(
            key: qrKey,
            onQRViewCreated: onQRViewCreated,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Iniciar escaneo manual si es necesario
          controller?.resumeCamera(); // Reanudar la cámara si estaba pausada
        },
        child: const Icon(Icons.camera), // Cambia el icono según tus necesidades
      ),
    );
  }
}
