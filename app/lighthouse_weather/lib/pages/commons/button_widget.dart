import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {

  ButtonWidget({Key key, this.label, this.iconData, this.action}) : super(key: key);

  final String label;
  final IconData iconData;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff2d485e)),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Color(0xff375670),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w300),
              ),
              Icon(
                iconData,
                color: Colors.white,
              ),
            ]),
      ),
      onTap: action,
    );
  }
}