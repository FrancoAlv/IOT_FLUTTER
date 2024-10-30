
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
        // Estado de autenticación del usuario
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;

        // Rutas Públicas (accesibles sin autenticación)
        final publicRoutes = ['/login', '/registre'];

        // Rutas Protegidas (requieren autenticación)
        final protectedRoutes = ['/', '/dashboard', '/profile'];

        // Verifica si el usuario está en una ruta pública
        final isPublicRoute = publicRoutes.contains(state.fullPath);
        // Verifica si el usuario está en una ruta protegida
        final isProtectedRoute = protectedRoutes.contains(state.fullPath);

        if (!isLoggedIn && isProtectedRoute) {
          // Redirige a /login si el usuario no está autenticado y trata de acceder a una ruta protegida
          return '/login';
        } else if (isLoggedIn && isPublicRoute) {
          // Redirige a la página de inicio si el usuario está autenticado y está en una ruta pública
          return '/';
        }

        // Si está en una ruta permitida según el estado de autenticación, no hacer redirección
        return state.fullPath;
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

        ],

      ),
      GoRoute(
        path: '/registre',
        builder: (BuildContext context, GoRouterState state) {

          return  RegistreView();
        },
      ),
    ],
  );

}



