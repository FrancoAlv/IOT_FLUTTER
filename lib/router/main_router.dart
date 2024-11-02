
import 'dart:async';

import 'package:app_iot_web/views/consts.dart';
import 'package:app_iot_web/views/contador/contador_view.dart';
import 'package:app_iot_web/views/init/init_view.dart';
import 'package:app_iot_web/views/login/login_view.dart';
import 'package:app_iot_web/views/perfil/perfil_view.dart';
import 'package:app_iot_web/views/policias/policias_add_view.dart';
import 'package:app_iot_web/views/policias/policias_edit_view.dart';
import 'package:app_iot_web/views/policias/policias_view.dart';
import 'package:app_iot_web/views/registre/registre_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';


sealed class MainRouter {

  static GoRouter router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      redirect: (context, state) {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;
        final publicRoutes = ['/login', '/registre'];
        final protectedRoutes = ['/', '/dashboard', '/profile',"/informacion_personal","/contador","/policias",];
        final isPublicRoute = publicRoutes.contains(state.fullPath);
        final isProtectedRoute = protectedRoutes.contains(state.fullPath);
        if (!isLoggedIn && isProtectedRoute) {
          return'/login';
        } else if (isLoggedIn && isPublicRoute) {
          return '/';
        }

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
      GoRoute(
        path: '/informacion_personal',
        builder: (BuildContext context, GoRouterState state) {
          return  PerfilView(showAppBar: true,);
        },
      ),
      GoRoute(
        path: '/contador',
        builder: (BuildContext context, GoRouterState state) {
          return  ContadorView();
        },
      ),
      GoRoute(
        path: '/policias',
        builder: (BuildContext context, GoRouterState state) {
          return  PoliciasView();
        },
        routes: [
          GoRoute(
            path: 'add',
            builder: (BuildContext context, GoRouterState state) {
              return PoliciasAddView();
            },
          ),
          GoRoute(
            path: 'edit',
            builder: (BuildContext context, GoRouterState state) {
              final nombre = state.extra != null ? (state.extra as Map)['nombre'] : '';
              final telefono = state.extra != null ? (state.extra as Map)['telefono'] : '';
              final correo = state.extra != null ? (state.extra as Map)['correo'] : '';
              final policiaId = state.extra != null ? checkInt((state.extra as Map)['policia_id'] ) ??0: 0;
              return PoliciasEditView(
                nombre: nombre,
                telefono: telefono,
                correo: correo,
                policiaID: policiaId,
              );
            },
          ),
        ],
      ),
    ],
  );
  static int? checkInt(dynamic value) {
    if(value is int) return value;
    if(value is double) return value.toInt();
    if(value is String) return int.tryParse(value);
    return null;
  }
}



