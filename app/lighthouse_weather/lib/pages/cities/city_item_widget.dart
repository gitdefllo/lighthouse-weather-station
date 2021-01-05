import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lighthouse_weather/bloc/city/city.dart';

import 'package:lighthouse_weather/models/city.dart';

class CityItem extends StatelessWidget {
  CityItem(this.city);

  final City city;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _pickCity(context),
        child: Card(
            color: Color(0xff375670),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Color(0xff2d485e), width: 1.0)),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(city.icon,
                    size: 40.0, color: Colors.white, semanticLabel: city.name),
                Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Text(city.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w300)))
              ],
            ))));
  }

  void _pickCity(BuildContext context) {
    var cityBloc = BlocProvider.of<CityBloc>(context);
    cityBloc.add(ChangeCity(city.id));
  }
}
