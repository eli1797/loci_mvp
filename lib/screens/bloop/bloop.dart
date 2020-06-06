import 'package:flutter/material.dart';

class Bloop extends StatefulWidget {
  @override
  _BloopState createState() => _BloopState();
}

class _BloopState extends State<Bloop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bloop Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, i) {
            if (i.isEven) {
              return _buildBox(Colors.blue);
            } else {
              return _buildBox(Colors.deepPurpleAccent);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBox(Color color) {
    BoxConstraints boxCon =  BoxConstraints(maxHeight: 50.0, maxWidth: 70.0);
    return Container( margin: EdgeInsets.all(12), constraints: boxCon, color: color);
  }
}
