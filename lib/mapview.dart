import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:praktikum/main.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

import 'dir.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final key = new GlobalKey<ScaffoldState>();

  bool _addEnabled = true;
  double circleRadius = 3;
  MapController mapController;
  List<CircleMarker> circleMarkers = [];
  List<int> pointTime = [];

  var circleRouteOne = <CircleMarker>[];
  var circleRouteTwo = <CircleMarker>[];

  String accuracy = "PRIORITY_LOW_POWER";

  var fixedRouteOne = <LatLng>[
    LatLng(51.48209, 7.21582),
    LatLng(51.48212, 7.21623),
    LatLng(51.48201, 7.21629),
    LatLng(51.48219, 7.21653),
    LatLng(51.48221, 7.21685),
    LatLng(51.4821, 7.21713),
    LatLng(51.48209, 7.21723),
    LatLng(51.48175, 7.21729),
    LatLng(51.48073, 7.21715),
    LatLng(51.48039, 7.21711),
    LatLng(51.48017, 7.21653),
  ];

  var fixedPointsOne = <LatLng>[
    LatLng(51.48209, 7.21602),
    LatLng(51.48219, 7.21652),
    LatLng(51.4822, 7.21686),
    LatLng(51.4821, 7.21719),
    LatLng(51.48174, 7.2173),
    LatLng(51.48136, 7.21724),
    LatLng(51.48073, 7.21715),
    LatLng(51.4804, 7.21711),
    LatLng(51.48019, 7.21651),
  ];

  var fixedRouteTwo = <LatLng>[
    LatLng(51.47975, 7.22276),
    LatLng(51.47942, 7.22202),
    LatLng(51.47912, 7.22253),
    LatLng(51.47898, 7.22268),
    LatLng(51.47886, 7.22282),
    LatLng(51.47799, 7.22382),
    LatLng(51.47788, 7.22388),
    LatLng(51.47782, 7.22364),
    LatLng(51.47793, 7.22348),
    LatLng(51.47795, 7.22332),
    LatLng(51.47771, 7.22279),
    LatLng(51.4786, 7.22175),
  ];

  var fixedPointsTwo = <LatLng>[
    LatLng(51.47966, 7.22254),
    LatLng(51.47938, 7.22209),
    LatLng(51.47923, 7.22229),
    LatLng(51.47912, 7.22252),
    LatLng(51.47888, 7.22279),
    LatLng(51.47845, 7.22331),
    LatLng(51.47807, 7.22376),
    LatLng(51.47789, 7.22352),
    LatLng(51.4777, 7.22276),
    LatLng(51.47807, 7.22227),
    LatLng(51.47837, 7.22193),
  ];

  @override
  void initState() {
    mapController = MapController();
    setState(() {
      fixedPointsOne.forEach((element) {
        circleRouteOne.add(CircleMarker(
            point: element,
            color: Colors.deepOrange.withOpacity(0.8),
            borderStrokeWidth: 0,
            useRadiusInMeter: true,
            radius: circleRadius));
      });
      fixedPointsTwo.forEach((element) {
        circleRouteTwo.add(CircleMarker(
            point: element,
            color: Colors.deepOrange.withOpacity(0.8),
            borderStrokeWidth: 0,
            useRadiusInMeter: true,
            radius: circleRadius));
      });
    });
  }

  Future<void> addPoint() async {
    String currentAccuracy = accuracy.toUpperCase();
    setState(() => _addEnabled = false);

    LocationAccuracy desiredAccuracy = LocationAccuracy.low;
    bool forceAndroidLocationManager = false;

    if (currentAccuracy == "PRIORITY_BALANCED_POWER_ACCURACY")
      desiredAccuracy = LocationAccuracy.medium;
    else if (currentAccuracy == "PRIORITY_HIGH_ACCURACY")
      desiredAccuracy = LocationAccuracy.high;
    else if (currentAccuracy == "PRIORITY_NO_POWER")
      desiredAccuracy = LocationAccuracy.lowest;
    else if (currentAccuracy == "PRIORITY_LOW_POWER")
      desiredAccuracy = LocationAccuracy.low;
    else if (currentAccuracy == "GPS_PROVIDER") {
      desiredAccuracy = LocationAccuracy.medium;
      forceAndroidLocationManager = true;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          forceAndroidLocationManager: forceAndroidLocationManager,
          desiredAccuracy: desiredAccuracy);
    } catch (e) {
      key.currentState.showSnackBar(new SnackBar(
        duration: new Duration(milliseconds: 1000),
        backgroundColor: Colors.red[900],
        content: new Text("Error getting Position ${e.runtimeType.toString()}"),
      ));
    }

    if (position == null) return;
    key.currentState.showSnackBar(new SnackBar(
      duration: new Duration(milliseconds: 1000),
      content:
          new Text("Position saved ($currentAccuracy/${position.accuracy})"),
    ));
    mapController.move(
        new LatLng(position.latitude, position.longitude), mapController.zoom);
    pointTime.add(DateTime.now().millisecondsSinceEpoch);

    setState(() {
      circleMarkers.add(CircleMarker(
          point: new LatLng(position.latitude, position.longitude),
          color: Colors.red.withOpacity(0.7),
          useRadiusInMeter: true,
          radius: circleRadius));
      _addEnabled = true;
    });
  }

  Future<bool> onWillPop() {
    if (circleMarkers.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      return Future.value(true);
    }
    AlertDialog alert = AlertDialog(
      title: Text("Exit?"),
      content: Text("You have unsaved changes!"),
      actions: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Exit"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement Loading with color Selection

    return Scaffold(
        key: key,
        appBar: AppBar(
          title: Text("Map View"),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add Point',
          child: Icon(Icons.add),
          backgroundColor: _addEnabled ? Colors.blueAccent : Colors.red,
          onPressed: _addEnabled ? () => addPoint() : null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.blueAccent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                tooltip: accuracy,
                icon: Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                onPressed: () async {
                  SelectDialog.showModal<String>(
                    context,
                    label: "Accuracy",
                    selectedValue: accuracy,
                    items: <String>[
                      "PRIORITY_NO_POWER",
                      "PRIORITY_LOW_POWER",
                      "GPS_PROVIDER",
                      "PRIORITY_BALANCED_POWER_ACCURACY",
                      "PRIORITY_HIGH_ACCURACY",
                    ],
                    showSearchBox: false,
                    onChange: (String selected) {
                      setState(() {
                        accuracy = selected;
                      });
                    },
                  );
                },
              ),
              Expanded(child: SizedBox()),
              IconButton(
                icon: Icon(
                  Icons.upload_file,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final granted = await PathUtils.requestPermissions();
                  if (!granted) return;
                  if (circleMarkers.isEmpty) return;
                  final dir = await PathUtils.getDownloadDirectory();
                  final resPath = path.join(dir.path,
                      "data_map_${DateTime.now().millisecondsSinceEpoch}.json");
                  File f = File(resPath);
                  Map<String, dynamic> x = {};
                  circleMarkers.asMap().forEach((index, point) {
                    if (index == 0) return;
                    x[pointTime[index - 1].toString()] = {
                      "lat": point.point.latitude,
                      "lng": point.point.longitude,
                    };
                  });
                  f.writeAsStringSync(JsonEncoder.withIndent(null).convert(x));
                  setState(() {
                    circleMarkers.clear();
                    pointTime.clear();
                  });
                  key.currentState.showSnackBar(new SnackBar(
                    duration: new Duration(milliseconds: 4000),
                    content: new Text("Map data saved"),
                    action: SnackBarAction(
                      label: "Open",
                      onPressed: () async {
                        OpenFile.open(resPath);
                      },
                    ),
                  ));
                },
              ),
            ],
          ),
        ),
        body: WillPopScope(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  center: LatLng(51.4475059, 7.2708202),
                  zoom: 13.0,
                  maxZoom: 18.0,
                  minZoom: 5.0),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                CircleLayerOptions(circles: circleMarkers),
                CircleLayerOptions(circles: circleRouteOne),
                CircleLayerOptions(circles: circleRouteTwo),
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: fixedRouteOne,
                        strokeWidth: 4.0,
                        color: Colors.black.withOpacity(0.5)),
                    Polyline(
                        points: fixedRouteTwo,
                        strokeWidth: 4.0,
                        color: Colors.black.withOpacity(0.5)),
                  ],
                ),
              ],
            ),
            onWillPop: onWillPop));
  }
}
