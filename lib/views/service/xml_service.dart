



import 'dart:convert';


import 'package:http/http.dart' as http;

import '../../core/constant/constant.dart';


class XmlService {
  static final String _baseUrl = AppStrings.urlApi;


  static Future<Map<String, String>> _getHeaders() async {

    return {
      //'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }


  // Método genérico para POST
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }



  // Método genérico para GET
  static Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final url = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParams);
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Manejar la respuesta
  static dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200: // OK
      case 201: // Created
      case 204: // No Content (para DELETE)
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
      case 403:
        throw Exception('No autorizado: ${response.body}');
      case 404:
        throw Exception('Recurso no encontrado');
      case 500:
        throw Exception('Error del servidor: ${response.body}');
      default:
        throw Exception('Error en la solicitud: ${response.statusCode}');
    }
  }
}
