import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/screens/home/home.dart';
import 'package:mvp/screens/profile/first_time_setup.dart';
import 'package:provider/provider.dart';


class HomeWrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<DocumentSnapshot>(context);
    print(userData);

    if (userData == null || (userData.exists && userData.data['firstName'] == "new_unnamed_member")) {
      return FirstTimeSetup();
    } else {
      return Home();
    }
  }
}
