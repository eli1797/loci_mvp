import 'package:flutter/material.dart';

class Bloop extends StatefulWidget {
  @override
  _BloopState createState() => _BloopState();
}

class _BloopState extends State<Bloop> {

  String message_0 = "This sounds like some dessert!";
  String message_1 = "Little shopping list for you. Could you buy me\ "
      "ice cream, oreos, and nutella? I am making a dessert for the party";
  String message_2 = 'What kind?';

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
              _buildCard(Colors.blue, text: message_1),
              _buildIndentedCard(Colors.deepPurpleAccent, text: message_2),
              _buildCard(Colors.deepPurpleAccent, text: message_0),
            ],
          )
      ),
    );
  }

  Container _buildBox(Color color) {
    BoxConstraints boxCon = BoxConstraints(maxHeight: 50.0, maxWidth: 50.0);
    return Container( margin: EdgeInsets.all(12), constraints: boxCon, color: color);
  }

  Widget _buildCard(Color color, {String text = "no u"}) {
    return Align(
      alignment: Alignment.centerLeft,
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

  Widget _buildIndentedCard(Color color, {String text = "no u"}) {
    return Align(
      alignment: FractionalOffset(0.05, 0.2),
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
