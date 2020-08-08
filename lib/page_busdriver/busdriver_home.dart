import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adminapp/custom_icons.dart';
import 'package:adminapp/model/busdriver_model.dart';
import 'package:adminapp/model/busposition_model.dart';
import 'package:adminapp/model/busstop_model.dart';
import 'package:adminapp/page/loginPage.dart';
import 'package:adminapp/page_admin/admin_home.dart';
import 'package:adminapp/page_admin/edit_driver.dart';
import 'package:adminapp/page_admin/manage_driver.dart';
import 'package:adminapp/page_busdriver/comment_page.dart';
import 'package:adminapp/page_busdriver/edit_busdriver.dart';
import 'package:adminapp/page_busdriver/work_schedule.dart';
import 'package:adminapp/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class BusdriverHome extends StatefulWidget {
  static List<BusdriverModel> busdriverModel = List<BusdriverModel>();

  @override
  _BusdriverHomeState createState() => _BusdriverHomeState();
}

class _BusdriverHomeState extends State<BusdriverHome> {
  List listSvg = [
    "star",
    "calendar",
  ];

  List listText = [
    "ความคิดเห็น",
    "ตาราการทำงาน",
  ];
  List<BusdriverModel> busdriverModel = BusdriverHome.busdriverModel;
  List<BusPositionModel> busPos = List<BusPositionModel>();
  List<BusstopModel> busstop = List<BusstopModel>();
  Size size;
  var _selection;
  bool checkWork = false;
  Location location = Location();
  LocationData currentLocation;
  DateTime _dataTime = DateTime.now();
  StreamSubscription stream;
  Timer timer;
  @override
  void initState() {
    super.initState();
    stream = location.onLocationChanged.listen((event) {
      print(event.latitude.toString() + ',' + event.longitude.toString());
      if (checkWork == true) {
        updateLocation();
      } else {}
    });
    // location.onLocationChanged.listen((event) {
    //   print(event.latitude.toString() + ',' + event.longitude.toString());
    //   if (checkWork == true) {
    //     updateLocation();
    //   } else {}
    // });
  }

  @override
  void dispose() {
    super.dispose();
    stream.cancel();
  }

  Future<Null> sentLocation() async {}
  // Future<Null> sentLocation() async {
  //   if (checkWork == true) {
  //     timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //       print('Timer : ' + timer.tick.toString());
  //       updateLocation();
  //     });
  //   } else {
  //     timer?.cancel();
  //   }
  // }

  Future getDataBusstop() async {
    var status = {};
    status['status'] = 'show';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busstop_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    busstop = jsonData.map((i) => BusstopModel.fromJson(i)).toList();
  }

  Future getDataDriver() async {
    var status = {};
    status['status'] = 'showId';
    status['id'] = busdriverModel[0].did;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busdriver_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    busdriverModel = jsonData.map((i) => BusdriverModel.fromJson(i)).toList();
    setState(() {});
  }

  void updateLocation() async {
    Location location = Location();
    currentLocation = await location.getLocation();
    String sid = '1';
    for (var i = 0; i < busstop.length; i++) {
      var lat = double.parse(busstop[i].sLongitude);
      var lng = double.parse(busstop[i].sLatitude);
      if ((lat >= (currentLocation.latitude - 0.0006) &&
              lat <= (currentLocation.latitude + 0.0006)) &&
          (lng >= (currentLocation.longitude - 0.0006) &&
              lng <= (currentLocation.longitude - 0.0006))) {
        sid = busstop[i].sid;
        print('Check point Sid : ' + sid);
      }
    }
    print('update location ' +
        currentLocation.latitude.toString() +
        ' ' +
        currentLocation.longitude.toString());
    var status = {};
    status['status'] = 'update';
    status['sid'] = sid;
    status['Cid'] = busdriverModel[0].cId;
    status['longitude'] = currentLocation.longitude.toString();
    status['latitude'] = currentLocation.latitude.toString();
    status['date'] = DateTime.now().toString();
    status['time'] = TimeOfDay.now().hour.toString() +
        ':' +
        TimeOfDay.now().minute.toString() +
        ':00';
    String jsonSt = json.encode(status);
    print(jsonSt);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busposition_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[dashBgone, dashBg, content],
      ),
    );
  }

  get dashBgone => Container(
        color: Colors.white,
      );

  get dashBg => Container(
        child: CustomPaint(
          painter: ShapesPainter(),
          child: Container(
            height: 350,
          ),
        ),
      );

  get content => Container(
        child: Column(
          children: <Widget>[
            header,
            containerShowProfile(),
            grid,
          ],
        ),
      );

  get header => ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 30),
        title: Text(
          'คนขับรถ',
          style: TextStyle(color: Color(0xFF3a3a3a), fontSize: 37),
        ),
        subtitle: Container(
          child: Row(
            children: <Widget>[
              InkWell(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons1.directions_bus,
                      size: 18,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      'Bus Tracking Project',
                      style: TextStyle(color: Color(0xFF3a3a3a), fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        trailing: InkWell(
          child: PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selection = value;
                if (value == 'Value1') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusDriverEdit(busdriverModel[0].did),
                    ),
                  ).then((value) => getDataDriver());
                } else if (value == 'Value2') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogingPage(),
                    ),
                  );
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Value1',
                child: ListTile(
                  title: Text('แก้ไขข้อมูลโปรไฟล์'),
                  trailing: Icon(Icons.edit),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Value2',
                child: ListTile(
                  title: Text('ออกจากระบบ'),
                  trailing: Icon(Icons1.logout_2),
                ),
              ),
            ],
            child: CircleAvatar(
              child: Icon(
                Icons1.cog_4,
                color: Color(0xFF3a3a3a),
                size: 30,
              ),
              backgroundColor: Colors.yellow[700],
            ),
          ),
          onTap: () {
            print('sdsd');
          },
        ),
      );

  Container containerShowProfile() {
    return Container(
      width: 300,
      child: Column(
        children: <Widget>[
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: (busdriverModel[0].dImage == '')
                    ? AssetImage('asset/icons/userIcon.png')
                    : NetworkImage(
                        'http://' +
                            Service.ip +
                            '/controlModel/showImage.php?name=' +
                            busdriverModel[0].dImage,
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons1.user_4),
                Text('  :  '),
                Text(
                  busdriverModel[0].dName,
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons1.directions_bus),
                Text('  :  '),
                Text(
                  busdriverModel[0].cId,
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          (checkWork == false)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: RaisedButton(
                    padding: EdgeInsets.fromLTRB(75, 10, 0, 10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'เริ่มออกรถ',
                          style: TextStyle(
                            fontSize: 35,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Icon(
                          Icons1.power_1,
                          size: 50,
                        )
                      ],
                    ),
                    color: Colors.red,
                    onPressed: () {
                      showMyDialog();
                      // setState(() {
                      //   sentLocation();
                      // });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: RaisedButton(
                    padding: EdgeInsets.fromLTRB(90, 10, 0, 10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'หยุดรถ',
                          style: TextStyle(
                            fontSize: 35,
                          ),
                        ),
                        SizedBox(
                          width: 42,
                        ),
                        Icon(
                          Icons1.power_1,
                          size: 50,
                        )
                      ],
                    ),
                    color: Colors.green,
                    onPressed: () {
                      checkWork = false;
                      setState(() {
                        sentLocation();
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  get grid {
    return Expanded(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 0),
        child: GridView.count(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 2,
          children: List.generate(listText.length, (int x) {
            return Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(color: Colors.white),
              ),
              child: InkWell(
                onTap: () {
                  print('object ');
                  if (x == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentPage(),
                        ));
                  } else if (x == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkSchedule(busdriverModel[0].cId),
                      ),
                    );
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image:
                            Svg('asset/svg/' + listSvg[x] + '.svg', height: 60),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 10),
                        child: Text(
                          listText[x],
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text(
                    'เริ่มออกรถ',
                    style: TextStyle(fontSize: ScreenUtil().setSp(80)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                    ),
                    onPressed: () {
                      checkWork = true;
                      setState(() {
                        sentLocation();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  Container(
                    width: 20,
                  ),
                  FlatButton(
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
