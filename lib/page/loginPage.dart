import 'dart:convert';
import 'dart:io';
import 'package:adminapp/page_admin/admin_home.dart';
import 'package:adminapp/page_busdriver/busdriver_home.dart';
import 'package:adminapp/service/service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class LogingPage extends StatefulWidget {
  @override
  _LogingPageState createState() => _LogingPageState();
}

class _LogingPageState extends State<LogingPage> {
  int id = 0;
  bool pass = false;
  String radioButtonItem = '';
  var status = {};
  List jsonData;
  bool _isHidden = true;
  bool _isLoading = false;
  var _passwordcontroller = TextEditingController();
  var _usernamecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Future loginAdmin() async {
    status['status'] = 'getProfile';
    status['username'] = _usernamecontroller.text;
    status['password'] = _passwordcontroller.text;
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/admin_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.body.toString());
    jsonData = json.decode(response.body);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminHome(),
      ),
    );
    _isLoading = false;
  }

  Future loginBusDriver() async {
    status['status'] = 'getProfile';
    status['username'] = _usernamecontroller.text;
    status['password'] = _passwordcontroller.text;
    String jsonSt = json.encode(status);
    print(jsonSt);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busdriver_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.body.toString());
    jsonData = json.decode(response.body);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BusdriverHome(),
      ),
    );
    _isLoading = false;
  }

  ListView listviewInput() {
    return ListView(
        padding:
            EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0, bottom: 20.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: 20.0, right: 20.0, left: 20.0, bottom: 10.0),
                child: Image.asset(
                  'asset/icons/msubuslogo.png',
                  height: 200,
                  width: 200,
                ),
              ),
              inputData(_usernamecontroller, 'ชื่อผู้ใช้งาน'),
              inputData(_passwordcontroller, 'รหัสผ่าน'),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: (radioButtonItem == '')
                    ? Text(
                        'กรุณาเลือกผู้ใช้งาน',
                        style: TextStyle(fontSize: 21),
                      )
                    : Text(
                        radioButtonItem,
                        style:
                            TextStyle(fontSize: 23, color: Colors.yellow[700]),
                      ),
              ),
              Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: id,
                      onChanged: (val) {
                        setState(() {
                          radioButtonItem = 'คนขับรถ';
                          id = 1;
                        });
                      },
                    ),
                    Text(
                      'คนขับรถ',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quark',
                      ),
                    ),
                    Radio(
                      value: 2,
                      groupValue: id,
                      onChanged: (val) {
                        setState(() {
                          radioButtonItem = 'ผู้ดูแลระบบ';
                          id = 2;
                        });
                      },
                    ),
                    Text(
                      'ผู้ดูแลระบบ',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quark',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              ButtonTheme(
                minWidth: 300.0,
                height: 60.0,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23.0),
                  ),
                  color: Colors.yellow[700],
                  child: Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 27.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quark',
                    ),
                  ),
                  onPressed: () {
                    print(_usernamecontroller.text);
                    print(_passwordcontroller.text);
                    setState(() {
                      _isLoading = true;
                      if (_usernamecontroller.text == '') {
                        Toast.show("กรุณาใส่ username", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        _isLoading = false;
                      } else if (_passwordcontroller.text == '') {
                        Toast.show("กรุณาใส่ password", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        _isLoading = false;
                      } else if (radioButtonItem == '') {
                        Toast.show("กรุณาเลือกผู้ใช้งาน !", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        _isLoading = false;
                      } else {
                        if (radioButtonItem == 'คนขับรถ') {
                          loginBusDriver();
                        } else if (radioButtonItem == 'ผู้ดูแลระบบ') {
                          loginAdmin();
                        }
                      }
                    });
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: Text('2020 \u00a9 BusTracking Project')),
              ),
            ],
          ),
        ]);
  }

  Padding inputData(controller, hintText) {
    return Padding(
        padding:
            EdgeInsets.only(top: 10.0, right: 0.0, left: 0.0, bottom: 10.0),
        child: Container(
          child: TextField(
            style: TextStyle(fontSize: 22.0),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 22.0,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              prefixIcon: hintText == "ชื่อผู้ใช้งาน"
                  ? Icon(Icons.email)
                  : Icon(Icons.lock),
              suffixIcon: hintText == "รหัสผ่าน"
                  ? IconButton(
                      onPressed: _toggleVisibility,
                      icon: _isHidden
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                    )
                  : null,
            ),
            controller: controller,
            obscureText: hintText == "รหัสผ่าน" ? _isHidden : false,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("asset/backgrounds/BG1.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter),
            color: Colors.grey[700]),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : listviewInput(),
      ),
    );
  }
}
