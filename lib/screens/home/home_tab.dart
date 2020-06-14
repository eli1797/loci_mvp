import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {


  DatabaseService _databaseService;
  final LocationService _locationService = LocationService();

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    _databaseService = DatabaseService(uid: user.uid);

    return StreamBuilder(
        stream: DatabaseService(uid: user.uid).streamFriendsData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          print("RuntimeType: " + snapshot.runtimeType.toString());
          print("Test: " + snapshot.hasError.toString());
          if (snapshot.hasData) {
//            UserFriends userFriends = snapshot.data;
            var userData = snapshot.data;
//            List<UserData> userDataList = snapshot.data;
            print(userData.length);
            userData.forEach((element) {
              print(element.firstName);
              print(element.openness);
              print(" ");
            });

            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Colors.blue,
                    child: Text('Update Location'),
                    onPressed: () async {
                      Position pos = await _locationService.getPosition();
                      await _databaseService.updateLocationWithGeo(pos);
                    },
                  ),
                  SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Friend First Name',
                      ),
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Enter a name';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Colors.blue,
                    child: Text('Add friend by UID'),
                    onPressed: () async {
                      print("_currentFriendName: " + _controller.text);
                      await _databaseService.addFriendByUID(_controller.text);
                      _controller.clear();
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Colors.blue,
                    child: Text('Query My Friends'),
                    onPressed: () async {
                      print("Pressed");
                    },
                  ),
                ],
              ),
            );
          } else {
            return Loading();
          }
        }
    );
  }
}
