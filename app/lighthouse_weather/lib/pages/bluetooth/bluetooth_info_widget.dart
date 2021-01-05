import 'package:flutter/material.dart';

class BluetoothInfo extends StatelessWidget {

  BluetoothInfo({Key key, this.icon, this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          alignment: Alignment.topCenter,
          margin: new EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Icon(
            icon,
            size: 28.0,
            color: Colors.white,
            semanticLabel: 'Icon',
          )),
      Card(
          color: Colors.transparent,
          elevation: 0.5,
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w300),
            ),
          ))
    ]);
  }
}
