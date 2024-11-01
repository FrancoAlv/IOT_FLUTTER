

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DawerView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email?? "";
    return  Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seguridad Vial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Usuario:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text('Listado de Familiares'),
            onTap: () {
              Navigator.pop(context);
              context.go('/familiares');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_police),
            title: const Text('Policías'),
            onTap: () {
              Navigator.pop(context);
              context.go('/policias');
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Seguro'),
            onTap: () {
              Navigator.pop(context);
              context.go('/seguro');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Información Personal'),
            onTap: () {
              Navigator.pop(context);
              context.go('/informacion_personal');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              final _auth = FirebaseAuth.instance;
              await _auth.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

}