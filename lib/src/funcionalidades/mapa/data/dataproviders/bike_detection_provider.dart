import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/bike_detection_response.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;

class BikeDetectionProvider {
  String? get _apiKey {
    return dotenv.env['AI_SERVICE_API_KEY'];
  }

 
  Future<bool> detectBike(File imageFile) async {
    try {
      
      final endpoint = dotenv.env['PESKAOS_ENDPOINT']; 
      
      if (kDebugMode) {
        print('Detecting bike in image: ${imageFile.path}');
        print('Endpoint: $endpoint');
      }

      final request = http.MultipartRequest('POST', Uri.parse(endpoint!));
      
      // Agregar API key en el header
      request.headers['X-API-Key'] = _apiKey ?? '';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Determinar el tipo MIME
      final mimeType = lookupMimeType(imageFile.path);
      MediaType? mediaType;
      if (mimeType != null) {
        final split = mimeType.split('/');
        if (split.length == 2) {
          mediaType = MediaType(split[0], split[1]);
        }
      }

    
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final detectionResponse = BikeDetectionResponse.fromJson(jsonResponse);

        if (!detectionResponse.success) {
          throw custom_exceptions.ServerException(
            detectionResponse.message.isNotEmpty
                ? detectionResponse.message
                : 'Error en la detección de bicicleta',
          );
        }

        if (detectionResponse.data == null) {
          throw custom_exceptions.ServerException(
            'No se recibieron datos de la detección',
          );
        }

        final confidence = detectionResponse.data!.confidence;
        final hasBike = detectionResponse.data!.hasBike;

        if (kDebugMode) {
          print('Bike detected: $hasBike, Confidence: $confidence%');
        }

        // Validar: confidence > 75% y hasBike = true
        return hasBike && confidence > 0.75;
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          print('Error response: $errorBody');
        }
        
        try {
          final errorJson = jsonDecode(errorBody);
          final errorMessage = errorJson['error'] ?? 
                              errorJson['message'] ?? 
                              'Error al detectar bicicleta';
          throw custom_exceptions.ServerException(errorMessage);
        } catch (e) {
          throw custom_exceptions.ServerException(
            'Error al detectar bicicleta: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (e is custom_exceptions.ServerException) {
        rethrow;
      }
      if (kDebugMode) {
        print('Exception detecting bike: $e');
      }
      throw custom_exceptions.ServerException(
        'Error de conexión al detectar bicicleta: ${e.toString()}',
      );
    }
  }
}

