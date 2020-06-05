import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home_tab.dart';
import 'package:mvp/screens/home/map_tab.dart';
import 'package:mvp/screens/profile/profile.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

//@Todo: might need to make Home stateful for updating -> unless it contains other widgts how are stateful??
class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _authService = AuthService();




  @override
  Widget build(BuildContext context) {

    //provider of the user model
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Loci'),
          backgroundColor: Colors.blue,
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.black,),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile())
                );
              })
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.near_me)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeTab(),
            MapTab()
        ]
        )

      ),
    );
  }
}
