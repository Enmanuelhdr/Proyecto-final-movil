import 'package:flutter/material.dart';
import 'package:shop/screens/home_screen.dart';
import 'package:shop/screens/notes.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({super.key});

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
              ),
              accountName: Text("Nombre: Enmanuel E. Heredia"),
              accountEmail: Text('Matricula: 2021-1938'),
              decoration: BoxDecoration(color: Colors.red)),
          ListTile(
            leading: const Icon(Icons.pets_rounded),
            title: const Text('Pokemons list'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const HomeScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notes'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const NotesScreen())),
          ),
        ],
      ),
    );
  }
}
