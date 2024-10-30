
import 'dart:async';

import 'package:app_iot_web/views/init/init_view.dart';
import 'package:app_iot_web/views/login/login_view.dart';
import 'package:app_iot_web/views/registre/registre_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';


sealed class MainRouter {

  abstract  String path;

  static GoRouter router = GoRouter(
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.path == '/login';

      if (!isLoggedIn && !loggingIn) {
        // Si el usuario no está autenticado y no está en la página de login, redirigir a login
        return '/login';
      } else if (isLoggedIn && loggingIn) {
        // Si el usuario está autenticado y está en la página de login, redirigir a init
        return '/';
      }
      // En cualquier otro caso, no hacer redirección
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',

        builder: (BuildContext context, GoRouterState state) {
          final _auth = FirebaseAuth.instance;
          if (_auth.currentUser!=null){
            return  InitView();
          }else{
            return  const LoginView();
          }
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {

              return  LoginView();
            },
          ),
          GoRoute(
            path: 'registre',
            builder: (BuildContext context, GoRouterState state) {

              return  RegistreView();
            },
          ),
        ],
      ),
    ],
  );

}



