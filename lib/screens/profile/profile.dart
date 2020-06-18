import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/profile/settings.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/location.dart';
import 'package:mvp/shared/constants.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  /// Instance of service for Cloud Firestore interaction
  DatabaseService _databaseService;

  /// Instance of service for getting or streaming location
  final LocationService _locationService = LocationService();

  /// Key for firstName and Status text editing
  final _formKey = GlobalKey<FormState>();

  /// State holder for openness slider
  double _sliderVal;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {
      // setup the instance of the database service
      _databaseService = DatabaseService(uid: user.uid);

      // stream the UserData
      return StreamBuilder<UserData>(
          stream: _databaseService.streamThisUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // create UserData model from Stream
              UserData userData = snapshot.data;
              // set _sliderVal starting value based on what's in the cloud
              _sliderVal = userData.openness ?? 0.0;
              return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: Text("Profile"),
                    actions: <Widget>[
                      Container(
                        height: 15.0,
                        width: 15.0,
                        decoration: BoxDecoration(
                          color: Constants.sliderColor[userData.openness ?? 0.0],
                          shape: BoxShape.circle,
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings()
                                )
                            );
                          })
                    ],
                  ),
                  body: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 20.0),
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 50.0,
                              child: Text('You'),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'First name',
                              ),
                              initialValue: userData.firstName,
                              onFieldSubmitted: (val) async {
                                //@Todo: validation on this and status text entry
                                await _databaseService.updateFirstName(
                                    val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Currently',
                              ),
                              initialValue: userData.status ?? '',
                              onFieldSubmitted: (val) async {
                                await _databaseService.updateStatus(
                                    val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            Text("Openness"),
                            Slider.adaptive(
                                min: 0.0,
                                max: 2,
                                divisions: 2,
                                value: _sliderVal ?? 0.0,
                                label: Constants.sliderLabel[_sliderVal],
                                activeColor: Constants.sliderColor[_sliderVal],
                                inactiveColor: Constants.sliderColor[_sliderVal],
                                onChanged: (val) => print(val),
                                onChangeEnd: (val) async {
                                  setState(() {
                                    _sliderVal = val;
                                  });
                                  await _databaseService.updateOpenness(val);
                                  if (val == 2.0) {
                                    print("going open");
                                    await _databaseService.goOpen(
                                      firstName: userData.firstName,
                                      status: userData.status,
                                      position: await _locationService.getPosition()
                                    );
                                  } else {
                                    print("going hidden");
                                    await _databaseService.goHidden();
                                  }
                                })
                          ],
                        ),
                      )
                  )
              );
            } else {
              return Loading();
            }
          });
    }
  }
}
