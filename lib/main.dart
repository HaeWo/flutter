import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:downloads_path_provider/downloads_path_provider.dart';

import 'package:sensors/sensors.dart';
import 'package:proximity_plugin/proximity_plugin.dart';
import 'package:enviro_sensors/enviro_sensors.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  XYZData _accelerometer = new XYZData(0, 0, 0);
  XYZData _gyroscope = new XYZData(0, 0, 0);
  XYZData _userAccelerometer = new XYZData(0, 0, 0);

  double _lightVal = 0;
  double _pressure = 0;
  double _humidity = 0;
  double _ambientTemp = 0;

  bool _start = false;

  Timer t;

  String fileData = "";

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

    t = new Timer.periodic(new Duration(seconds: 1), (Timer t) async {
      if (!_start) return;
      print("running");

      fileData += "Gravity: " + _accelerometer.toString() + "\n";
      fileData += "Acceleration: " + _userAccelerometer.toString() + "\n";
      fileData += "Gyroscope: " + _gyroscope.toString() + "\n";
      fileData += "\n\n";
    });

    super.initState();
  }

  @override
  void dispose() {
    t.cancel();
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // We didn't ask for permission yet.
      await openAppSettings();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // -------- LIGHT --------
              Row(
                children: [
                  Text(
                    "Light",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "$_lightVal lx",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),

              // -------- PRESSURE --------
              Row(
                children: [
                  Text(
                    "Pressure",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "$_pressure hPa",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),

              // -------- HUMIDITY --------
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                children: [
                  Text(
                    "Humidity",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "$_humidity %",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),

              // -------- Temperature --------
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                children: [
                  Text(
                    "Temperature",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "$_ambientTemp °C",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),

              // -------- ACCELEROMETER --------
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                children: [
                  Text(
                    "Accelerometer (with Gravity)",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "[\n${_accelerometer.x},\n${_accelerometer.y},\n${_accelerometer.z}\n]",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),

              // -------- GYROSCOPE --------
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                children: [
                  Text(
                    "Gyroscope",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "[\n${_gyroscope.x},\n${_gyroscope.y},\n${_gyroscope.z}\n]",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),

              // -------- Accelerometer without gravity --------
              Padding(
                padding: EdgeInsets.only(top: 15),
              ),
              Row(
                children: [
                  Text(
                    "Accelerometer (without Gravity)",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.5),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "[\n${_userAccelerometer.x},\n${_userAccelerometer.y},\n${_userAccelerometer.z}\n]",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            DefaultTextStyle.of(context).style.fontSize * 0.45),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: _start ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        backgroundColor: _start ? Colors.redAccent : Colors.blueAccent,
        onPressed: () async {
          if (!_start) {
            final granted = await _requestPermissions();
            if (!granted) return;
          } else {
            final dir = await _getDownloadDirectory();
            final resPath = path.join(
                dir.path, "data_${DateTime.now().millisecondsSinceEpoch}.txt");
            File f = File(resPath);
            f.writeAsStringSync(fileData);
            fileData = "";
          }

          setState(() {
            _start = !_start;
          });
        },
      ),
    );
  }
}
