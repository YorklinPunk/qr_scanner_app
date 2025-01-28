class UpdateModel {
  final int codigo;
  final String nombres;
  final String apellidos;
  final String correo;

  UpdateModel({
    required this.codigo,
    required this.nombres,
    required this.apellidos,
    required this.correo,
  });

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      codigo: json['codigo'],
      nombres: json['Nombres'],
      apellidos: json['Apellidos'],
      correo: json['Correo']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'Nombres': nombres,
      'Apellidos': apellidos,
      'Correo': correo,
    };
  }
}
