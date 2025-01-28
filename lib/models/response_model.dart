class ResponseModel {
  final bool success;
  final String message;
  final String error;

  ResponseModel({
    required this.success,
    required this.message,
    required this.error,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      success: json['success'],
      message: json['message'],
      error: json['error']
    );
  }
}