import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'funcionalidades/usuario/apresentacao/controladores/cadastro_controlador.dart';
import 'funcionalidades/usuario/apresentacao/controladores/login_controlador.dart';
import 'funcionalidades/usuario/apresentacao/controladores/atualizar_dados_controlador.dart';
import 'funcionalidades/usuario/apresentacao/paginas/cadastro_pagina.dart';
import 'funcionalidades/usuario/apresentacao/paginas/inicial_pagina.dart';
import 'funcionalidades/usuario/apresentacao/paginas/escolha_nivel_pagina.dart';
import 'funcionalidades/treino/apresentacao/paginas/treino_pagina.dart';
import 'funcionalidades/treino/apresentacao/paginas/exercicios_lista_pagina.dart';
import 'funcionalidades/treino/apresentacao/paginas/exercicios_video_pagina.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📩 Mensagem recebida em background: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'canal_principal',
        'Notificações Gerais',
        channelDescription: 'Canal de notificações do WOApp',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CadastroControlador()),
        ChangeNotifierProvider(create: (_) => LoginControlador()),
        ChangeNotifierProvider(create: (_) => AtualizarDadosControlador()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WOApp',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1B2B2A),
        ),
        initialRoute: '/inicial',
        routes: {
          '/inicial': (_) => const InicioPagina(),
          '/cadastro': (_) => const CadastroPagina(),
          '/escolha-nivel': (_) => const EscolhaNivelPagina(),
          '/treino/exercicios': (_) => const ExerciciosListaPagina(tipo: 'academia'),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/treino') {
            final args = settings.arguments as Map<String, dynamic>;
            final nivel = args['nivel'] ?? 'iniciante';
            return MaterialPageRoute(
              builder: (_) => TreinoPagina(nivel: nivel),
            );
          }
          if (settings.name == '/treino/video') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ExercicioVideoPagina(
                titulo: args['titulo'] ?? 'Exercício',
                subtitulo: args['subtitulo'] ?? '',
                urlVideo: args['urlVideo'] ?? '',
                imagem: '',
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}