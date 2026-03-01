import 'dart:convert';

import 'package:nomina_control/features/device/domain/entities/device_credentials.dart';


class DeviceCredentialsModel extends DeviceCredentials {

  const DeviceCredentialsModel({
    required super.host,
    super.port,
    required super.login,
    required super.password,
  });
  factory DeviceCredentialsModel.parse(String string) {
     final json  =  jsonDecode(string) as Map<String, dynamic>;
     final port = int.tryParse(json['port']?.toString() ?? '');
     return DeviceCredentialsModel(
       host: json['host'],
       port:  port,
       login: json['login'],
       password: json['password'],
     );
  }
  factory DeviceCredentialsModel.fromEntity(DeviceCredentials credentials) {
    return DeviceCredentialsModel(
      host: credentials.host,
      port: credentials.port,
      login: credentials.login,
      password: credentials.password,
    );
  }
  @override
  String toString() {
    return  jsonEncode({
      'host': host,
      'port': port,
      'login': login,
      'password': password,
    });
  }

}