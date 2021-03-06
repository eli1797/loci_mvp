import 'dart:collection';

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

  /// Chip selected
  bool _single;

  List<String> chipList = [
    "One",
    "Two",
    "Three",
    "Four"
  ];

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
                                onChanged: (val) => {},
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
                                }),
                            SizedBox(height: 10.0),
                            Flexible(
                              child: Container(
                                  child: ChoiceChipsWidget(chipList, _databaseService),
//                              child: Wrap(
//                                spacing: 5.0,
//                                runSpacing: 5.0,
//                                children: <Widget>[
//                                  ChoiceChipWidget("One", _databaseService),
//                                  ChoiceChipWidget("Two", _databaseService),
//                                  ChoiceChipWidget("Three", _databaseService),
//                                  ChoiceChipWidget("Four", _databaseService),
//                                ],
//                              )
                              ),
                            )
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
class ChoiceChipsWidget extends StatefulWidget {

  /// Chip titles
  List<String> chipList;

  /// DatabaseService for interacting with Cloud Firestore
  DatabaseService _databaseService;

  /// Constructor
  ChoiceChipsWidget(this.chipList, this._databaseService);

  @override
  _ChoiceChipsWidgetState createState() => _ChoiceChipsWidgetState();
}

class _ChoiceChipsWidgetState extends State<ChoiceChipsWidget> {

  /// Title and active bool for each chip
  LinkedHashMap<String, bool> _chipVals;


  _buildChoiceChips() {
    List<Widget> choices = List();

    _chipVals.entries.forEach((element) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(element.key),
          labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Color(0xffededed),
          selectedColor: Colors.blue,
          selected: element.value ?? false,
          onSelected: (val) {
            if (val) {
              widget._databaseService.activateTag(element.key);
            } else {
              widget._databaseService.deactivateTag(element.key);
            }
            setState(() {
              _chipVals.update(element.key, (value) => val);
            });
          },
        ),
      )
      );
    });
    return choices;
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, bool>>(
      stream: widget._databaseService.streamTags(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.toString());
          _chipVals = LinkedHashMap.from(snapshot.data);

          return Wrap(
            children: _buildChoiceChips(),
          );
        } else {
          return Wrap();
        }

      });
  }
}


class ChoiceChipWidget extends StatefulWidget {

  /// Title and value the chip represents
  final String chipVal;

  /// DatabaseService for interacting with Cloud Firestore
  DatabaseService _databaseService;

  /// Constructor
  ChoiceChipWidget(this.chipVal, this._databaseService);

  @override
  _ChoiceChipWidgetState createState() => _ChoiceChipWidgetState();
}

class _ChoiceChipWidgetState extends State<ChoiceChipWidget> {

  /// Stateholder for whether or not the chip is selected
  bool _selected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, bool>>(
        stream: widget._databaseService.streamTags(),
        builder: (context, snapshot) {
          print("Howdy" + snapshot.toString());
          if (snapshot.hasData) {
            _selected = snapshot.data[widget.chipVal] ?? false;
            print("1");
          }

          return ChoiceChip(
            label: Text(widget.chipVal),
            labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            backgroundColor: Color(0xffededed),
            selectedColor: Colors.blue,
            selected: _selected ?? false,
            onSelected: (val) {
              setState(() {
                _selected = val;
                if (val) {
                  widget._databaseService.activateTag(widget.chipVal);
                } else {
                  widget._databaseService.deactivateTag(widget.chipVal);
                }
              });
            },
          );
        });
  }
}


