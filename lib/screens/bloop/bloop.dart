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
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, i) {
//            if (i.isEven) {
//              return _buildBox(Colors.blue);
//            } else {
//              return _buildBox(Colors.deepPurpleAccent);
//            }
            if (i.isEven) {
              return _buildCard(Colors.blue, true);
            } else {
              return _buildCard(Colors.deepPurpleAccent, false);
            }
          },
        ),
      ),
    );
  }

  Container _buildBox(Color color) {
    BoxConstraints boxCon = BoxConstraints(maxHeight: 50.0, maxWidth: 50.0);
    return Container( margin: EdgeInsets.all(12), constraints: boxCon, color: color);
  }

  Widget _buildCard(Color color, bool alignLeft) {
    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No u"),
        ),
      ),
    );
  }
}
