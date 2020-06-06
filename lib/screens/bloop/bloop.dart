import 'package:flutter/material.dart';

class Bloop extends StatefulWidget {
  @override
  _BloopState createState() => _BloopState();
}

class _BloopState extends State<Bloop> {

  String message_0 = "This sounds like some dessert!";
  String message_1 = "Little shopping list for you. Could you buy me\ "
      "ice cream, oreos, and nutella? I am making a dessert for the party";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bloop Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            children: <Widget>[
              _buildCard(Colors.deepPurpleAccent, true, text: message_0),
              _buildCard(Colors.blue, true, text: message_1),
            ],
          )
      ),
    );
  }

  Container _buildBox(Color color) {
    BoxConstraints boxCon = BoxConstraints(maxHeight: 50.0, maxWidth: 50.0);
    return Container( margin: EdgeInsets.all(12), constraints: boxCon, color: color);
  }

  Widget _buildCard(Color color, bool alignLeft, {String text = "no u"}) {
    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Card(
        color: color,
        child: InkWell(
          onTap: () {
            print("Tapped");
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}