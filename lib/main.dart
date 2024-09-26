import 'package:admin_it_material_panel/drawer_pages/carouselslider_photos.dart';
import 'package:admin_it_material_panel/drawer_pages/technology.dart';
import 'package:admin_it_material_panel/drawer_pages/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCodP9sOVOENTZBu6JKGPMub1g2Q0baqec',
      appId: '1:373637410895:web:f41487400948731df8ba3a',
      messagingSenderId: '373637410895',
      projectId: 'it-materials-point',
      authDomain: 'it-materials-point.firebaseapp.com',
      storageBucket: 'it-materials-point.appspot.com',
      measurementId: 'G-TB2FWT4HHQ',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin IT Material Point',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const users(),
    const technology(),
    CarouselsliderPhotos()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "IT ",
              style: TextStyle(
                  fontFamily: "karsyu",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white70),
            ),
            Text(
              "Material ",
              style: TextStyle(
                  fontFamily: "karsyu",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.blueGrey),
            ),
            Text(
              "Point",
              style: TextStyle(
                  fontFamily: "karsyu",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.tealAccent),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Drawer(
              width: !_show ? 65 : 180,
              child: ListView(
                // padding: EdgeInsets.zero,
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_search_outlined),
                    title: Text(
                      _show ? 'Users' : '',
                      style: const TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_ethernet_outlined),
                    title: Text(
                      _show ? 'Technology' : '',
                      style: const TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(
                      _show ? 'Carousel slider Photos' : '',
                      style: const TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      _onItemTapped(2);
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _show = !_show;
                        });
                      },
                      icon: Icon(
                        !_show
                            ? Icons.arrow_forward_ios_outlined
                            : Icons.arrow_back_ios,
                        size: 20,
                      )),
                ],
              ),
            ),
            SizedBox(
              width: !_show ? 1423 : 1328,
              child: _pages[_selectedIndex],
            )
          ],
        ),
      ),
    );
  }
}
