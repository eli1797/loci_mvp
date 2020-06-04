import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/profile/profile.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:provider/provider.dart';

//@Todo: might need to make Home stateful for updating -> unless it contains other widgts how are stateful??
class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  // first name entry
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();


  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //provider of the user model
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    }

    final DatabaseService _databaseService = DatabaseService(uid: user.uid);

    _locationService.checkPermission();

    return Scaffold(
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
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            RaisedButton(
              color:  Colors.blue,
              child: Text('Update Location'),
              onPressed: () async {
                Position pos =  await _locationService.getPosition();
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
              color:  Colors.blue,
              child: Text('Add friend by FirstName'),
              onPressed: () async {
                print("_currentFriendName: " + _controller.text);
                await _databaseService.addFriendByFirstName(_controller.text);
                _controller.clear();
              },
            ),
            SizedBox(height: 20.0),
            RaisedButton(
              color:  Colors.blue,
              child: Text('Query My Friends'),
              onPressed: () async {
                Position pos =  await _locationService.getPosition();
//                print("Querying from $pos");
//                print("Friends");
                // Note all this contains is a uid, its not actually a user data
                List<UserData> friends = await _databaseService.queryFriends();
                friends.forEach((element) async {
                  print(element.uid);
                  print(element.firstName);
                  print(element.gfp.longitude);
                  print(element.gfp.latitude);
                  print("");

                  print(await _locationService.distanceFromMe(pos, element.gfp.latitude, element.gfp.longitude));
                });

//                await Future.wait(friends.map((e) async {
//                    var result = await _locationService.distanceFromMe(pos, e.gfp.latitude, e.gfp.longitude);
//                    print(result);
//                }));
              },
            )
          ],
        ),
      )

    );
  }
}
