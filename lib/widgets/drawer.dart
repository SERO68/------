import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../UI/azkar/azkarscreen.dart';
import '../UI/homescreen.dart';
import '../UI/settingsscreen.dart';
import '../provider/model.dart';


class Drawerapp extends StatelessWidget {
  const Drawerapp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<Model>(
        builder: (context, model, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      'images/sidemenu.jpg',
                    ),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Container(
                          width: constraints.maxWidth * 0.9,
                          height: constraints.maxHeight * 0.65,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            image: DecorationImage(
                              image: model.image,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight * 0.07,
                        ),
                        Text(
                          model.profileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ListTile(
                splashColor: Colors.blue,
                leading: const Icon(Icons.house),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Homescreen()),
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
              ),
              ListTile(
                splashColor: Colors.blue,
                leading: const Icon(Icons.star),
                title: const Text('Favorite'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AzkarScreen()));
                },
              ),
              ListTile(
                splashColor: Colors.blue,
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
