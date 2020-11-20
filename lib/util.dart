/*
 * @Description: 工具类函数
 * @author: xiaoxin
 * @Date: 2020-06-14 10:59:01
 * @lastEditors: xiaoxin
 * @LastEditTime: 2020-11-20 10:46:07
 * @FilePath: /wx_calander_app/lib/utils/util.dart
 * @GlobalData: data
 */

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

// import 'package:image_picker/image_picker.dart';
import 'dart:convert' as convert;

/// <wbf==============================

/*
 * @description: setTimeout计时器
 * @param {VoidCallback} fn 执行函数
 * @param {int} millis 时间ms
 */
Timer setTimeout(VoidCallback fn, int millis) {
  Timer timer;
  if (millis > 0)
    timer = new Timer(new Duration(milliseconds: millis), fn);
  else
    fn();
  return timer;
}

/*
 * @description: 清除Interval计时器
 * @param {int} timer
 */
void clearInterval(Timer timer) {
  try {
    timer.cancel();
  } catch (e) {}
}

/*
 * @description:setInterval计时器
 * @param {VoidCallback} fn 执行函数
 * @param {int} millis 时间ms
 */
Timer setInterval(VoidCallback fn, int millis) {
  Timer timer;
  if (millis > 0)
    timer = new Timer.periodic(new Duration(milliseconds: millis), (timer) {
      fn();
    });
  else
    fn();
  return timer;
}

/*
 * @description: 颜色转换类
 * @param {String} hexColor
 * @return: Color
 */
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
