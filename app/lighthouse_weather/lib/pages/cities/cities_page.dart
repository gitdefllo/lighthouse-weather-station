import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart' show Guid;

import 'package:lighthouse_weather/bloc/bluetooth/bluetooth.dart';
import 'package:lighthouse_weather/bloc/city/city.dart';

import 'package:lighthouse_weather/data/cities_data.dart';

import 'package:lighthouse_weather/models/city.dart';

import 'package:lighthouse_weather/pages/commons/background_widget.dart';
import 'package:lighthouse_weather/pages/cities/city_item_widget.dart';

class CitiesPage extends StatefulWidget {
  @override
  CitiesPageState createState() {
    return CitiesPageState();
  }
}

class CitiesPageState extends State<CitiesPage> {
  final Guid _WEATHER_SERVICE_GUID = Guid('00000000-8cb1-44ce-9a66-001dca0941a6');

  @override
  Widget build(BuildContext context) {
    var bleBloc = BlocProvider.of<BleBloc>(context);

    return BlocProvider(
        create: (_) => CityBloc(bleBloc.getServiceByGuid(_WEATHER_SERVICE_GUID)),
        child: BlocBuilder<CityBloc, CityState>(builder: (context, state) {
          return Scaffold(
              body: Stack(
            children: [
              BackgroundImage('bg_cities'),
              _showContent(state),
            ],
          ));
        }));
  }

  Widget _showContent(CityState state) {
    if (state is CityUpdatingFailed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('An error occurred, the city is not updated'),
        duration: const Duration(seconds: 3),
      ));
    }

    if (state is CityUpdated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    return GridView.count(
      crossAxisCount: 3,
      children: _getCityItems(),
    );
  }

  List<Widget> _getCityItems() {
    var list = List<Widget>();
    var citiesData = CitiesData();
    citiesData.cities.forEach((element) {
      var city =
          City(element['id'], name: element['name'], icon: element['icon']);
      var item = CityItem(city);
      list.add(item);
    });
    return list;
  }
}
