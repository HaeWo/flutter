import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
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

  double circleRadius = 3;
  MapController mapController;
  var circleMarkers = <CircleMarker>[];
  var pointTime = <int>[];

  String accuracy = "PRIORITY_HIGH_ACCURACY";

  var fixedRouteOne = <LatLng>[
    LatLng(51.44755, 7.27101),
    LatLng(51.44787, 7.27198),
    LatLng(51.44729, 7.27252),
    LatLng(51.44697, 7.27149),
    LatLng(51.44664, 7.27176),
    LatLng(51.44685, 7.27245),
    LatLng(51.44659, 7.27269),
    LatLng(51.44646, 7.27227),
    LatLng(51.44628, 7.27211),
    LatLng(51.44618, 7.27217),
    LatLng(51.44581, 7.27276),
    LatLng(51.44543, 7.27283),
    LatLng(51.44526, 7.27285),
    LatLng(51.44516, 7.27271),
    LatLng(51.44513, 7.27293),
    LatLng(51.44525, 7.27284),
    LatLng(51.44581, 7.27275),
    LatLng(51.44622, 7.27282),
    LatLng(51.44629, 7.27295),
  ];

  var fixedRouteTwo = <LatLng>[
    LatLng(51.44791, 7.27069),
    LatLng(51.44841, 7.27176),
    LatLng(51.44898, 7.27144),
    LatLng(51.44918, 7.27129),
    LatLng(51.44933, 7.27099),
    LatLng(51.44944, 7.27109),
    LatLng(51.45009, 7.27246),
    LatLng(51.4504, 7.273),
    LatLng(51.45068, 7.2733),
    LatLng(51.45108, 7.27347),
    LatLng(51.45146, 7.27329),
    LatLng(51.45155, 7.27342),
    LatLng(51.45269, 7.27272),
    LatLng(51.45296, 7.27266),
    LatLng(51.45302, 7.27308),
    LatLng(51.45291, 7.27308),
    LatLng(51.4527, 7.27317),
    LatLng(51.45265, 7.27337),
    LatLng(51.45169, 7.27383),
    LatLng(51.45161, 7.27395),
    LatLng(51.45079, 7.27374),
    LatLng(51.45075, 7.27379),
    LatLng(51.45073, 7.27377),
    LatLng(51.45053, 7.27448),
    LatLng(51.45052, 7.27483),
    LatLng(51.45082, 7.27603),
    LatLng(51.45038, 7.27638),
    LatLng(51.4484, 7.27198),
    LatLng(51.4484, 7.27172),
    LatLng(51.44792, 7.2707),
  ];

  @override
  void initState() {
    mapController = MapController();
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      print(position);
      LatLng currentPos = new LatLng(position.latitude, position.longitude);
      setState(() {
        mapController.move(currentPos, 18.0);
        circleMarkers.add(CircleMarker(
            point: currentPos,
            color: Colors.blue.withOpacity(0.7),
            borderStrokeWidth: 2,
            useRadiusInMeter: true,
            radius: circleRadius));
      });
    });
  }

  Future<void> addPoint() async {
    Position position;
    switch (accuracy.toUpperCase()) {
      case "PRIORITY_BALANCED_POWER_ACCURACY":
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        break;
      case "PRIORITY_HIGH_ACCURACY":
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        break;
      case "PRIORITY_NO_POWER":
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest);
        break;
      case "PRIORITY_LOW_POWER":
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        break;
      case "GPS_PROVIDER":
      default:
        position = await Geolocator.getCurrentPosition(
            forceAndroidLocationManager: true);
        break;
    }
    if (position == null) return;
    LatLng currentPos = new LatLng(position.latitude, position.longitude);
    key.currentState.showSnackBar(new SnackBar(
      duration: new Duration(milliseconds: 1000),
      content: new Text("Position saved"),
    ));
    setState(() {
      mapController.move(currentPos, mapController.zoom);
      circleMarkers.add(CircleMarker(
          point: currentPos,
          color: Colors.red.withOpacity(0.7),
          useRadiusInMeter: true,
          radius: circleRadius));
      pointTime.add(DateTime.now().millisecondsSinceEpoch);
    });
  }

  Future<bool> onWillPop() {
    if (circleMarkers.length == 1) return Future.value(true);
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
            Navigator.of(context).pop();
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
          backgroundColor: Colors.blueAccent,
          onPressed: () => addPoint(),
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
                  if (circleMarkers.length <= 1) return;
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
                    circleMarkers = <CircleMarker>[circleMarkers[0]];
                    pointTime = <int>[];
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
