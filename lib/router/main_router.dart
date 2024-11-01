
import 'dart:async';

import 'package:app_iot_web/views/consts.dart';
import 'package:app_iot_web/views/contador/contador_view.dart';
import 'package:app_iot_web/views/init/init_view.dart';
import 'package:app_iot_web/views/login/login_view.dart';
import 'package:app_iot_web/views/perfil/perfil_view.dart';
import 'package:app_iot_web/views/policias/policias_view.dart';
import 'package:app_iot_web/views/registre/registre_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';


sealed class MainRouter {

  static GoRouter router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      redirect: (context, state) {
        if (Consts.keyrouter =="/contador"){
          Consts.keyrouter ="";
          return "/contador" ;
        }
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
      ),
    ],
  );

}



