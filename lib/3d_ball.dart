/*
 * @Author: your name
 * @Date: 2020-10-27 14:04:44
 * @LastEditTime: 2020-11-20 11:13:19
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \wx_calander_app\lib\pages\familyCloud\3d_ball.dart
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/user_level_model.dart';
import 'package:flutter_app/xball_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThreeBallPage extends StatefulWidget {
  @override
  _ThreeBallPageState createState() => _ThreeBallPageState();
}

class _ThreeBallPageState extends State<ThreeBallPage> {
  List<UserLevelModel> themeList;
  List<UserLevelModel> coreList;
  List<UserLevelModel> lineList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalData();
  }

  //获取本地json
  Future getLocalData() async {
    rootBundle.loadString("images/3d.json").then((value) {
      Map map = jsonDecode(value);

      if (map['motif'] != null) {
        List motif = map['motif'];
        List<UserLevelModel> motifDemo = [];
        for (var i = 0; i < motif.length; i++) {
          UserLevelModel model = UserLevelModel.fromJson(motif[i]);
          motifDemo.add(model);
        }
        setState(() {
          themeList = motifDemo;
        });
      }
      if (map['norm'] != null) {
        List norm = map['norm'];
        List<UserLevelModel> normDemo = [];
        for (var i = 0; i < norm.length; i++) {
          UserLevelModel model = UserLevelModel.fromJson(norm[i]);
          normDemo.add(model);
        }
        setState(() {
          coreList = normDemo;
        });
      }
      if (map['line'] != null) {
        List line = map['line'];
        List<UserLevelModel> lineDemo = [];
        for (var i = 0; i < line.length; i++) {
          UserLevelModel model = UserLevelModel.fromJson(line[i]);
          lineDemo.add(model);
        }
        setState(() {
          lineList = lineDemo;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/3d_bg.png"),
            fit: BoxFit.cover,
          ),
        )),
        Positioned(
            top: MediaQuery.of(context).padding.top + 30 + 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  height: 30,
                  child: Text(
                    '3D旋转',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                XBallView(
                  mediaQueryData: MediaQuery.of(context),
                  keywords: themeList,
                  highlight: coreList,
                  lineList: lineList,
                ),
              ],
            ))
      ],
    );
  }
}
