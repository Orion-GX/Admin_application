import 'dart:convert';
import 'dart:io';

import 'package:adminapp/custom_icons.dart';
import 'package:adminapp/model/admin_model.dart';
import 'package:adminapp/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class EDitByAdmin extends StatefulWidget {
  @override
  _EDitByAdminState createState() => _EDitByAdminState();
}

class _EDitByAdminState extends State<EDitByAdmin> {
  var status = {};
  var _usernamecontroller = TextEditingController();
  var _passwordcontroller = TextEditingController();
  var _emailcontroller = TextEditingController();
  var _tellcontroller = TextEditingController();
  String id;
  List<AdminModel> admin = List<AdminModel>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getDataAdmin();
  }

  void setText(List<AdminModel> ad) {
    this.id = ad[0].aid;
    _usernamecontroller.text = ad[0].username;
    _passwordcontroller.text = ad[0].password;
    _emailcontroller.text = ad[0].email;
    _tellcontroller.text = ad[0].tell;
    loading = true;
  }

  Future<Null> sentDataAdmin() async {
    status['status'] = 'edit';
    status['id'] = this.id;
    status['username'] = _usernamecontroller.text;
    status['password'] = _passwordcontroller.text;
    status['tell'] = _tellcontroller.text;
    status['email'] = _emailcontroller.text;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/admin_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    if (response.statusCode == 200) {
      if (response.body.toString() == 'Bad') {
        setState(() {
          Toast.show("ไม่สามารถแก้ไขข้อมูลได้", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        Toast.show("แก้ไขข้อมูลสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }
    } else {}
  }

  Future<Null> getDataAdmin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getInt('tokenId'));
    status['id'] = pref.getInt('tokenId');
    status['status'] = 'showId';
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/admin_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    List jsonData = json.decode(response.body);
    admin = jsonData.map((e) => AdminModel.fromJson(e)).toList();
    setText(admin);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'แก้ไขข้อมูลผู้ดูแล',
        style: TextStyle(
          color: Color(0xFF3a3a3a),
          fontSize: ScreenUtil().setSp(60),
        ),
      )),
      body: Container(
        child: loading == false
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('กำลังโหลดข้อมูล'),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Container(
                              height: 230,
                              width: 320,
                              child: Wrap(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 10, 5, 10),
                                          child: CircleAvatar(
                                            backgroundImage: ExactAssetImage(
                                                'asset/icons/admin.png'),
                                            radius: 110,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //******************       username         ************** */
                          Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                  child: Container(
                                    child: TextField(
                                      style: TextStyle(
                                          fontSize: 22.0, height: 1.0),
                                      decoration: InputDecoration(
                                        labelText: 'ชื่อผู้ใช้งาน',
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'ชื่อผู้ใช้งาน',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 22.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
                                        ),
                                        prefixIcon: Icon(Icons1.user_5),
                                      ),
                                      readOnly: true,
                                      controller: _usernamecontroller,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Container(
                                  child: TextField(
                                    style:
                                        TextStyle(fontSize: 22.0, height: 1.0),
                                    decoration: InputDecoration(
                                      labelText: 'รหัสผ่าน',
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'รหัสผ่าน',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 22.0,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      prefixIcon: Icon(Icons1.key_2),
                                    ),
                                    controller: _passwordcontroller,
                                  ),
                                ),
                              ),
                              //******************       email         ************** */
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Container(
                                  child: TextField(
                                    style:
                                        TextStyle(fontSize: 22.0, height: 1.0),
                                    decoration: InputDecoration(
                                      labelText: 'อีเมล์',
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'อีเมล์',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 22.0,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      prefixIcon: Icon(Icons1.email),
                                    ),
                                    controller: _emailcontroller,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Container(
                                  child: TextField(
                                    style:
                                        TextStyle(fontSize: 22.0, height: 1.0),
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      labelText: 'เบอร์โทร',
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'เบอร์โทร',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 22.0,
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      prefixIcon: Icon(Icons1.phone_1),
                                    ),
                                    controller: _tellcontroller,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              ButtonTheme(
                                minWidth: ScreenUtil().setWidth(650),
                                height: ScreenUtil().setHeight(170),
                                child: RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23.0),
                                  ),
                                  color: Colors.blue[700],
                                  child: Text(
                                    "ยืนยันการแก้ไขข้อมูล",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quark',
                                    ),
                                  ),
                                  onPressed: () async {
                                    sentDataAdmin();
                                  },
                                ),
                              ),
                            ],
                          ),
                          //******************       password         ************** */
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
