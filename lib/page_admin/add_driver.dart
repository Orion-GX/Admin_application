import 'dart:convert';
import 'dart:io';

import 'package:adminapp/custom_icons.dart';
import 'package:adminapp/model/bus_model.dart';
import 'package:adminapp/model/busdriver_model.dart';
import 'package:adminapp/service/service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http_parser/http_parser.dart';

class AddBusDriver extends StatefulWidget {
  @override
  _AddBusDriverState createState() => _AddBusDriverState();
}

class _AddBusDriverState extends State<AddBusDriver> {
  var status = {};
  var _usernamecontroller = TextEditingController();
  var _passwordcontroller = TextEditingController();
  var _emailcontroller = TextEditingController();
  var _namecontroller = TextEditingController();
  var _imagecontroller = TextEditingController();
  var _datecontroller = TextEditingController();
  var _gendercontroller = TextEditingController();
  var _tellcontroller = TextEditingController();
  File image;
  String value = '';
  var bit;
  bool show = true;
  int id;
  bool userB = false,
      passB = false,
      nameB = false,
      genB = false,
      emailB = false,
      dateB = false,
      tellB = false;
  String radioButtonItem;
  DateTime _dataTime = DateTime.now();
  List<BusModel> bus = List<BusModel>();

  @override
  void initState() {
    super.initState();
  }

  Future<Null> addTransciption() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    status['status'] = 'add';
    status['aid'] = pref.getInt('tokenId');
    status['type'] = 'เพิ่มข้อมูลคนขับ ' + _namecontroller.text;
    status['time'] = DateTime.now().toString();
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/transcription_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Map<String, dynamic>> _uploadImage() async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse('http://' + Service.ip + '/controlModel/upload.php'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    print(mimeTypeData[0]);
    print(mimeTypeData[1]);
    print(image.path);
    print(file.filename);
    bit = file.filename;
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        Toast.show("ชื่อผู้ใช้ไม่สามารถใช้งานได้", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return null;
      } else {
        var res = await _sentDataBusDriver();
        Toast.show("เพิ่มข้อมูลสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Null> _sentDataBusDriver() async {
    status['status'] = 'add';
    status['username'] = _usernamecontroller.text;
    status['password'] = _passwordcontroller.text;
    status['name'] = _namecontroller.text;
    if (id == 1) {
      _gendercontroller.text = 'male';
    } else {
      _gendercontroller.text = 'female';
    }
    status['sex'] = _gendercontroller.text;
    status['busId'] = value;
    status['tell'] = _tellcontroller.text;
    status['email'] = _emailcontroller.text;
    status['date'] = _dataTime.toString();
    if (bit == null) {
      status['image'] = _imagecontroller.text;
    } else {
      status['image'] = bit;
    }
    String jsonSt = json.encode(status);
    var response = await http.post(
        'http://' + Service.ip + '/controlModel/busdriver_model.php',
        body: jsonSt,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    print(response.statusCode.toString() + ' ' + response.body.toString());
    if (response.statusCode == 200) {
      if (response.body.toString() == 'Bad') {
        setState(() {
          Toast.show("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        Toast.show("เพิ่มข้อมูลสำเร็จ", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        bit = '';
        Navigator.pop(context);
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'เพิ่มข้อมูลคนขับรถ',
        textScaleFactor: 1.2,
        style: TextStyle(
          color: Color(0xFF3a3a3a),
        ),
      )),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 230,
                      width: 320,
                      child: Wrap(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              (image != null)
                                  ? Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 230,
                                        ),
                                        child: Image.file(
                                          image,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 5, 10),
                                        child: CircleAvatar(
                                          backgroundImage: ExactAssetImage(
                                              'asset/icons/student.png'),
                                          radius: 110,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () async {
                              var img;
                              try {
                                img = await ImagePicker.pickImage(
                                    source: ImageSource.camera);
                                image = img;
                              } catch (e) {}

                              setState(() {});
                            },
                            colorBrightness: Brightness.light,
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[700],
                                ),
                                Divider(),
                                Container(
                                  width: 10,
                                ),
                                Text(
                                  'ถ่ายรูป',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 22.0,
                                  ),
                                ),
                              ],
                            )),
                        VerticalDivider(),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey,
                        ),
                        VerticalDivider(),
                        FlatButton(
                          onPressed: () async {
                            var img;
                            try {
                              img = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              image = img;
                            } catch (e) {}

                            setState(() {});
                          },
                          colorBrightness: Brightness.light,
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            // Replace with a Row for horizontal icon + text
                            children: <Widget>[
                              Icon(
                                Icons1.picture_3,
                                color: Colors.grey[700],
                              ),
                              Divider(),
                              Container(
                                width: 10,
                              ),
                              Text(
                                'แกลลอรี่',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 22.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    //******************       username         ************** */
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Container(
                            child: TextField(
                              style: TextStyle(fontSize: 22.0, height: 1.0),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  userB = false;
                                }
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                errorStyle: TextStyle(fontSize: 16),
                                errorText: userB == true
                                    ? 'กรุณากรอกชื่อผู้ใช้งาน'
                                    : null,
                                labelText: 'ชื่อผู้ใช้งาน',
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'ชื่อผู้ใช้งาน',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 22.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                prefixIcon: Icon(Icons1.user_5),
                              ),
                              controller: _usernamecontroller,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Container(
                            child: TextField(
                              style: TextStyle(fontSize: 22.0, height: 1.0),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  passB = false;
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                errorStyle: TextStyle(fontSize: 16),
                                errorText:
                                    passB == true ? 'กรุณากรอกรหัสผ่าน' : null,
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Container(
                            child: TextField(
                              style: TextStyle(fontSize: 22.0, height: 1.0),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  nameB = false;
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                errorStyle: TextStyle(fontSize: 16),
                                errorText: nameB == true
                                    ? 'กรุณากรอกชื่อ นามสกุล'
                                    : null,
                                labelText: 'ชื่อ นามสกุล',
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'ชื่อ นามสกุล',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 22.0,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                prefixIcon: Icon(Icons.verified_user),
                              ),
                              controller: _namecontroller,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: id != 3 ? 1 : 2,
                                  color:
                                      id != 3 ? Colors.grey[600] : Colors.red,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons1.user_male,
                                    color: Colors.grey[500],
                                  ),
                                  Container(
                                    width: 12,
                                  ),
                                  Text(
                                    'เพศ',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quark',
                                    ),
                                  ),
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
                                    'ชาย',
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
                                    'หญิง',
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
                          ),
                        ),
                        //******************       email         ************** */
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Container(
                            child: TextField(
                              style: TextStyle(fontSize: 22.0, height: 1.0),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  emailB = false;
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                errorStyle: TextStyle(fontSize: 16),
                                errorText: emailB == true
                                    ? 'กรุณากรอกอีเมลล์ให้ถูกต้อง'
                                    : null,
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
                            height: 60,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[600],
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: Colors.white),
                            child: InkWell(
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _dataTime,
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(2030),
                                ).then((value) {
                                  setState(() {
                                    if (value != null) {
                                      _dataTime = value;
                                    }
                                  });
                                });
                              },
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 11),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons1.calendar_3,
                                        color: Colors.grey[500],
                                      ),
                                      Container(
                                        width: 12,
                                      ),
                                      (_dataTime == null)
                                          ? Text('วันเดือนปี',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 22,
                                              ))
                                          : Text(
                                              _dataTime.day.toString() +
                                                  '/' +
                                                  _dataTime.month.toString() +
                                                  '/' +
                                                  _dataTime.year.toString(),
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 22,
                                              )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                          child: Container(
                            child: TextField(
                              style: TextStyle(fontSize: 22.0, height: 1.0),
                              maxLength: 10,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  tellB = false;
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                errorStyle: TextStyle(fontSize: 16),
                                errorText:
                                    tellB == true ? 'กรุณากรอกเบอร์โทร' : null,
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
                              keyboardType: TextInputType.phone,
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
                              "ยืนยันการเพิ่มข้อมูล",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Quark',
                              ),
                            ),
                            onPressed: () async {
                              print(id);
                              if (_usernamecontroller.text.isEmpty) {
                                userB = true;
                              }
                              if (_passwordcontroller.text.isEmpty) {
                                passB = true;
                              }
                              if (_namecontroller.text.isEmpty) {
                                nameB = true;
                              }
                              if (id != 1 && id != 2) {
                                id = 3;
                              }
                              if (_emailcontroller.text.isEmpty ||
                                  EmailValidator.validate(
                                          _emailcontroller.text) !=
                                      true) {
                                emailB = true;
                              }
                              if (_tellcontroller.text.isEmpty ||
                                  _tellcontroller.text.length != 10) {
                                tellB = true;
                              }
                              if (userB == false &&
                                  passB == false &&
                                  nameB == false &&
                                  emailB == false &&
                                  tellB == false) {
                                try {
                                  if (image == null) {
                                    _sentDataBusDriver();
                                  } else {
                                    final Map<String, dynamic> response =
                                        await _uploadImage();
                                  }
                                } catch (e) {}
                              } else {
                                Toast.show("กรุณากรอกข้อมูลให้ครบ", context,
                                    duration: Toast.LENGTH_LONG,
                                    gravity: Toast.BOTTOM);
                                setState(() {});
                              }
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
