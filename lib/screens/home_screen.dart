import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'qr_scanner_screen.dart';


class HomeScreen extends StatefulWidget {
  final ApiService apiService;
  const HomeScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<UserModel>> _usersFuture;
  bool showScanner = false; // Controla si se muestra el escáner QR

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = widget.apiService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers, // Recargar la lista
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Text('Correo: ${user.email}\nTeléfono: ${user.phoneNumber}'),
                    trailing: Icon(
                      user.status ? Icons.check_circle : Icons.cancel,
                      color: user.status ? Colors.green : Colors.grey,
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la nueva pantalla
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()), // Cambia NewScreen por tu clase de destino
          );
        },
        child: const Icon(Icons.qr_code_scanner), // Cambia el icono según tus necesidades
      ),
    );
  }  
}