class UserModel {
  final int id;
  final String timestamp;
  final String firstName;
  final String lastName;
  final String email;
  final int phoneNumber;
  final bool status;

  UserModel({
    required this.id,
    required this.timestamp,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['IdColumn'],
      timestamp: json['Marca temporal'],
      firstName: json['Nombres'],
      lastName: json['Apellidos'].toString(),
      email: json['Correo electrónico'],
      phoneNumber: json['Número celular'],
      status: json['Estado'],
    );
  }
}
