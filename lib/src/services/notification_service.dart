import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException;
import 'package:nextmove_app/config/graphql_config.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/dataproviders/auth_remote_data_provider.dart';

// Handler para mensajes en primer plano
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  bool _initialized = false;

  String? get fcmToken => _fcmToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Solicitar permisos
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Inicializar notificaciones locales para Android
        await _initializeLocalNotifications();

        // Configurar handlers
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // Obtener token inicial
        try {
          _fcmToken = await _firebaseMessaging.getToken();
          
          if (kDebugMode) {
            print('FCM Token: $_fcmToken');
          }

          // Registrar token si el usuario está autenticado
          if (FirebaseAuth.instance.currentUser != null && _fcmToken != null) {
            await registerFCMToken(_fcmToken!);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error obteniendo token FCM inicial: $e');
          }
        }

        // Escuchar cambios en el token
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          if (kDebugMode) {
            print('FCM Token refrescado: $newToken');
          }
          _fcmToken = newToken;
          if (FirebaseAuth.instance.currentUser != null) {
            registerFCMToken(newToken);
          }
        });

        _initialized = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  /// Inicializa las notificaciones locales para Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationPayload(response.payload!);
        }
      },
    );

    // Crear canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'station_alerts', // id
      'Alertas de Estaciones', // name
      description: 'Notificaciones sobre espacios disponibles en estaciones de bici',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Maneja mensajes en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
    }

    // Mostrar notificación local
    if (message.notification != null) {
      await _showLocalNotification(
        message.notification!.title ?? 'Alerta de Estación',
        message.notification!.body ?? '',
        message.data,
      );
    }
  }

  /// Maneja el click en notificaciones cuando la app está en background
  Future<void> _handleNotificationClick(RemoteMessage message) async {
    if (kDebugMode) {
      print('Notification clicked!');
      print('Message data: ${message.data}');
    }
    _handleNotificationPayload(message.data);
  }

  /// Muestra una notificación local
  Future<void> _showLocalNotification(String title, String body, Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'station_alerts',
      'Alertas de Estaciones',
      channelDescription: 'Notificaciones sobre espacios disponibles en estaciones de bici',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: data['stationId'],
    );
  }

  /// Callback para manejar el payload de la notificación
  Function(String)? onNotificationTap;

  /// Maneja el payload de la notificación
  void _handleNotificationPayload(dynamic payload) {
    if (payload is String && payload.isNotEmpty) {
      if (kDebugMode) {
        print('Notification payload: $payload');
      }
      // Llamar al callback si está definido
      onNotificationTap?.call(payload);
    }
  }

  /// Configura el callback para cuando se hace tap en una notificación
  void setOnNotificationTap(Function(String stationId) callback) {
    onNotificationTap = callback;
  }

  /// Registra el token FCM en el backend
  Future<bool> registerFCMToken(String token) async {
    try {
      String? authHeader = await AuthRemoteDataProvider().authHeader;
      if (authHeader == null) {
        if (kDebugMode) {
          print('No auth header, cannot register FCM token');
        }
        return false;
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.registerFCMToken),
        variables: {
          'input': {
            'fcmToken': token,
            'platform': 'android',
            'deviceId': null, // Opcional, puedes añadir un identificador único del dispositivo
          },
        },
        context: Context().withEntry(
          HttpLinkHeaders(headers: {'Authorization': authHeader}),
        ),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLConfig.client.value.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error registering FCM token: ${result.exception}');
        }
        return false;
      }

      if (kDebugMode) {
        print('FCM token registered successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error registering FCM token: $e');
      }
      return false;
    }
  }

  /// Elimina el token FCM del backend
  Future<bool> deleteFCMToken(String token) async {
    try {
      String? authHeader = await AuthRemoteDataProvider().authHeader;
      if (authHeader == null) {
        return false;
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.deleteFCMToken),
        variables: {'fcmToken': token},
        context: Context().withEntry(
          HttpLinkHeaders(headers: {'Authorization': authHeader}),
        ),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLConfig.client.value.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error deleting FCM token: ${result.exception}');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
      return false;
    }
  }

  Future<String?> getToken() async {
    if (!_initialized) {
      await initialize();
    }
    
    if (_fcmToken != null) {
      return _fcmToken;
    }
    
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode && _fcmToken != null) {
        if (kDebugMode) {
          print('FCM Token obtenido: $_fcmToken');
        }
      }
      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo token FCM: $e');
      }
      return null;
    }
  }
}


