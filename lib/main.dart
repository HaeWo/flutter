import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;

import 'package:sensors/sensors.dart';
import 'package:proximity_plugin/proximity_plugin.dart';
import 'package:enviro_sensors/enviro_sensors.dart';
import 'package:geolocator/geolocator.dart';

import 'mapview.dart';
import 'dir.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hä!Wo?',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Hä!Wo?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class XYZData {
  double x = 0;
  double y = 0;
  double z = 0;

  XYZData(this.x, this.y, this.z);

  @override
  String toString() {
    return "{${this.x},${this.y},${this.z}}";
  }
}

class ExportSettings {
  bool accelerometer = false;
  bool gyroscope = false;
  bool userAccelerometer = false;
  bool lightVal = false;
  bool pressure = false;
  bool humidity = false;
  bool ambientTemp = false;
  bool location = false;
}

class _MyHomePageState extends State<MyHomePage> {
  final key = new GlobalKey<ScaffoldState>();

  XYZData _accelerometer = new XYZData(0, 0, 0);
  XYZData _gyroscope = new XYZData(0, 0, 0);
  XYZData _userAccelerometer = new XYZData(0, 0, 0);

  double _lightVal = 0;
  double _pressure = 0;
  double _humidity = 0;
  double _ambientTemp = 0;

  bool _start = false;

  Position _position;

  Timer t;

  Map<String, dynamic> fileData = {};

  ExportSettings settings = new ExportSettings();

  double _durationTime = 1.0;
  double _durationCounter = 0.0;

  @override
  void initState() {
    accelerometerEvents.listen((event) {
      setState(() => _accelerometer = new XYZData(event.x, event.y, event.z));
    });

    userAccelerometerEvents.listen((event) {
      setState(
          () => _userAccelerometer = new XYZData(event.x, event.y, event.z));
    });

    gyroscopeEvents.listen((event) {
      setState(() => _gyroscope = new XYZData(event.x, event.y, event.z));
    });

    proximityEvents.listen((event) {
      print(event.x);
    });

    barometerEvents.listen((BarometerEvent event) {
      setState(() => _pressure = event.reading);
    });

    lightmeterEvents.listen((LightmeterEvent event) {
      setState(() => _lightVal = event.reading);
    });

    ambientTempEvents.listen((AmbientTempEvent event) {
      setState(() => _ambientTemp = event.reading);
    });

    humidityEvents.listen((HumidityEvent event) {
      setState(() => _humidity = event.reading);
    });

    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
        .listen((Position position) {
      setState(() => _position = position);
    });

    t = new Timer.periodic(new Duration(seconds: 1), (Timer t) async {
      if (!_start) return;
      _durationCounter++;
      print("running");
      if (_durationCounter < _durationTime) return;
      Map<String, dynamic> current = {};
      if (settings.accelerometer) {
        current["accelerometer"] = [
          _accelerometer.x,
          _accelerometer.y,
          _accelerometer.z
        ];
      }
      if (settings.gyroscope) {
        current["gyroscope"] = [_gyroscope.x, _gyroscope.y, _gyroscope.z];
      }
      if (settings.userAccelerometer) {
        current["userAccelerometer"] = [
          _userAccelerometer.x,
          _userAccelerometer.y,
          _userAccelerometer.z
        ];
      }

      if (settings.lightVal) {
        current["light"] = _lightVal;
      }
      if (settings.pressure) {
        current["pressure"] = _pressure;
      }
      if (settings.pressure) {
        current["pressure"] = _pressure;
      }
      if (settings.humidity) {
        current["humidity"] = _humidity;
      }
      if (settings.ambientTemp) {
        current["ambientTemp"] = _ambientTemp;
      }

      if (settings.location) {
        if (_position == null) {
          current["location"] = null;
        } else {
          current["location"] = {
            "lat": _position.latitude,
            "lng": _position.longitude,
            "altitude": _position.altitude,
            "speed": _position.speed,
            "accuracy": _position.accuracy,
            "heading": _position.heading
          };
        }
      }

      fileData[DateTime.now().millisecondsSinceEpoch.toString()] = current;

      key.currentState.showSnackBar(new SnackBar(
        duration: new Duration(milliseconds: 500),
        content: new Text("Wrote new data"),
      ));
    });

    super.initState();
  }

  @override
  void dispose() {
    t.cancel();
  }

  List<Widget> rowItem(
      String name, String text, bool value, Function(bool) onChange) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: DefaultTextStyle.of(context).style.fontSize * 0.4),
          ),
          Checkbox(value: value, onChanged: onChange),
        ],
      ),
      Row(
        children: [
          Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: DefaultTextStyle.of(context).style.fontSize * 0.45),
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(top: 15),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(Slider(
      value: _durationTime,
      min: 1,
      max: 100,
      divisions: 100,
      label: "${_durationTime.round().toString()} Sekunden",
      onChanged: (double value) {
        setState(() {
          _durationTime = value;
        });
      },
    ));
    rows.addAll(rowItem("Light", "$_lightVal lx", settings.lightVal,
        (val) => settings.lightVal = val));
    rows.addAll(rowItem("Pressure", "$_pressure hPa", settings.pressure,
        (val) => settings.pressure = val));
    rows.addAll(rowItem("Humidity", "$_humidity %", settings.humidity,
        (val) => settings.humidity = val));
    rows.addAll(rowItem("Temperature", "$_ambientTemp °C", settings.ambientTemp,
        (val) => settings.ambientTemp = val));
    rows.addAll(rowItem(
        "Accelerometer (with Gravity)",
        "[\n${_accelerometer.x},\n${_accelerometer.y},\n${_accelerometer.z}\n]",
        settings.accelerometer,
        (val) => settings.accelerometer = val));
    rows.addAll(rowItem(
        "Gyroscope",
        "[\n${_gyroscope.x},\n${_gyroscope.y},\n${_gyroscope.z}\n]",
        settings.gyroscope,
        (val) => settings.gyroscope = val));
    rows.addAll(rowItem(
        "Accelerometer (without Gravity)",
        "[\n${_userAccelerometer.x},\n${_userAccelerometer.y},\n${_userAccelerometer.z}\n]",
        settings.userAccelerometer,
        (val) => settings.userAccelerometer = val));
    rows.addAll(rowItem(
        "Location",
        _position == null
            ? "Unknown"
            : "Lat: ${_position.latitude.toString()}\n"
                "Lng: ${_position.longitude.toString()}\n"
                "Heading: ${_position.heading}\n"
                "Height: ${_position.altitude}\n"
                "Accuracy: ${_position.accuracy}",
        settings.location,
        (val) => settings.location = val));

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Datensammler'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('MapView'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapView()),
                );
              },
            )
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: rows,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: _start ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        backgroundColor: _start ? Colors.redAccent : Colors.blueAccent,
        onPressed: () async {
          if (!_start) {
            final granted = await PathUtils.requestPermissions();
            if (!granted) return;
          } else {
            final dir = await PathUtils.getDownloadDirectory();
            final resPath = path.join(
                dir.path, "data_${DateTime.now().millisecondsSinceEpoch}.json");
            File f = File(resPath);
            f.writeAsStringSync(JsonEncoder.withIndent(null).convert(fileData));
            fileData = {};
          }

          setState(() {
            _start = !_start;
          });
        },
      ),
    );
  }
}
