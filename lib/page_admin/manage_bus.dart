import 'dart:convert';
import 'dart:io';

import 'package:adminapp/custom_icons.dart';
import 'package:adminapp/model/bus_model.dart';
import 'package:adminapp/model/busdriver_model.dart';
import 'package:adminapp/page_admin/add_bus.dart';
import 'package:adminapp/page_admin/edit_bus.dart';
import 'package:adminapp/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ManageBus extends StatefulWidget {
  @override
  _ManageBusState createState() => _ManageBusState();
}

class _ManageBusState extends State<ManageBus> {
  List<BusModel> listBus = List<BusModel>();
  List<BusdriverModel> listDriver = List<BusdriverModel>();
  List<BusModel> listBusSearch = List<BusModel>();
  TextEditingController editcontroller = TextEditingController();
  bool loadData = false;
  bool isSearch = false;
  var status = {};
  String text = '2';
  int ch = 0;

  @override
  void initState() {
    super.initState();
    getDataBus();
    getDataDriver();
  }

  Future<Null> addTransciption(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    status['status'] = 'add';
    status['aid'] = pref.getInt('tokenId');
    status['type'] = 'ลบข้อมูลรถรางไอดี ' + id;
    status['time'] = DateTime.now().toString();
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/transcription_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<void> deleteBusPosition(String text) async {
    var status = {};
    status['status'] = 'delete';
    status['cid'] = text;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busposition_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Null> getDataBus() async {
    listBusSearch.clear();
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/bus_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    listBus = jsonData.map((i) => BusModel.fromJson(i)).toList();
    listBusSearch.addAll(listBus);
    filterSearchResults(editcontroller.text);
    ch++;
    if (ch == 2) {
      ch = 0;
      loadData = true;
      setState(() {});
    }
  }

  Future getDataDriver() async {
    status['status'] = 'show';
    status['id'] = '';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busdriver_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    listDriver = jsonData.map((i) => BusdriverModel.fromJson(i)).toList();
    ch++;
    if (ch == 2) {
      ch = 0;
      loadData = true;
      setState(() {});
    }
  }

  Future<Null> deleteBus(String id) async {
    status['status'] = 'delete';
    status['cid'] = id;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/bus_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.body + ' ' + response.statusCode.toString());
    if (response.statusCode == 200) {
      if (response.body.toString() == 'Bad') {
        setState(() {
          Toast.show("ลบข้อมูลไม่สำเร็จ", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else if (response.body.toString() == 'Good') {
        Toast.show("ลบข้อมูลสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        addTransciption(id);
        deleteBusPosition(id);
        getDataBus();
        getDataDriver();
      }
    } else {
      setState(() {});
    }
  }

  void filterSearchResults(String query) {
    List<BusModel> dummySearchListBus = List<BusModel>();
    List<BusdriverModel> dummySearchListDriver = List<BusdriverModel>();
    dummySearchListBus.addAll(listBus);
    dummySearchListDriver.addAll(listDriver);
    if (query.isNotEmpty) {
      List<BusModel> dummyListDataBus = List<BusModel>();
      List<BusdriverModel> dummyListDataDriver = List<BusdriverModel>();
      dummySearchListBus.forEach((item) {
        if ((item.cid.toLowerCase()).contains(query)) {
          dummyListDataBus.add(item);
        }
      });
      setState(() {
        listBusSearch.clear();
        listBusSearch.addAll(dummyListDataBus);
      });
      return;
    } else {
      setState(() {
        listBusSearch.clear();
        listBusSearch.addAll(listBus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearch == true
            ? Directionality(
                textDirection: Directionality.of(context),
                child: TextField(
                  key: Key('SearchBarTextField'),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: 'ค้นหารถ',
                      hintStyle: TextStyle(fontSize: 20),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none),
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  autofocus: true,
                  controller: editcontroller,
                ),
              )
            : Text(
                'จัดการข้อมูลรถ',
                style: TextStyle(
                  color: Color(0xFF3a3a3a),
                  fontSize: ScreenUtil().setSp(60),
                ),
              ),
        actions: <Widget>[
          isSearch == true
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 27,
                  ),
                  onPressed: () {
                    editcontroller.text = '';
                    filterSearchResults('');
                    isSearch = false;
                    setState(() {});
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 27,
                  ),
                  onPressed: () {
                    isSearch = true;
                    setState(() {});
                  },
                ),
          isSearch == true
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBus(),
                        )).then((value) {
                      getDataBus();
                      getDataDriver();
                    });
                  },
                ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: listBusSearch.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        listBusSearch[index].cid,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: ScreenUtil().setSp(55),
                        ),
                      ),
                      subtitle: listDriver.length == 0
                          ? Text(
                              '',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: ScreenUtil().setSp(35),
                              ),
                            )
                          : Text(
                              'ชื่อคนขับ : ' +
                                  checkDriver(
                                      listDriver, listBusSearch[index].did),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: ScreenUtil().setSp(40),
                              ),
                            ),
                      trailing: Wrap(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons1.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditBus(listBusSearch[index]),
                                  )).then((value) {
                                getDataBus();
                                getDataDriver();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons1.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              deleteBus(listBusSearch[index].cid);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String checkDriver(List<BusdriverModel> listDriver, String did) {
    for (int i = 0; i < listDriver.length; i++) {
      if (listDriver[i].did == did) {
        return listDriver[i].dName;
      } else {}
    }
    return '';
  }
}
