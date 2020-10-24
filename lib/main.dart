import 'package:flutter/material.dart';

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
}

class _MyHomePageState extends State<MyHomePage> {
  XYZData _accelerometer = new XYZData(0, 0, 0);
  XYZData _gyroscope = new XYZData(0, 0, 0);

  double _lightVal = 0;
  double _pressure = 0;
  double _humidity = 0;
  double _ambientTemp = 0;

  @override
  void initState() {
    accelerometerEvents.listen((event) {
      setState(() {
        _accelerometer = new XYZData(event.x, event.y, event.z);
      });
    });

    gyroscopeEvents.listen((event) {
      setState(() {
        _gyroscope = new XYZData(event.x, event.y, event.z);
      });
    });

    proximityEvents.listen((event) {
      print(event.x);
    });

    barometerEvents.listen((BarometerEvent event) {
      setState(() {
        _pressure = event.reading;
      });
    });

    lightmeterEvents.listen((LightmeterEvent event) {
      setState(() {
        _lightVal = event.reading;
      });
    });

    ambientTempEvents.listen((AmbientTempEvent event) {
      setState(() {
        _ambientTemp = event.reading;
      });
    });

    humidityEvents.listen((HumidityEvent event) {
      setState(() {
        _humidity = event.reading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
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
                  "Accelerometer",
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

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
