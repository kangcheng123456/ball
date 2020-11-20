import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/user_level_model.dart';
import 'package:flutter_app/util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//手指按下时命中的point
PointAnimationSequence pointAnimationSequence;
//球半径
int radius = 10;

class XBallView extends StatefulWidget {
  final MediaQueryData mediaQueryData;

  ///需要展示的关键词
  final List<UserLevelModel> keywords;

  ///需要高亮的关键词
  final List<UserLevelModel> highlight;
  final List<UserLevelModel> lineList;
  const XBallView({
    Key key,
    @required this.mediaQueryData,
    @required this.keywords,
    @required this.highlight,
    @required this.lineList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _XBallViewState();
  }
}

class _XBallViewState extends State<XBallView>
    with SingleTickerProviderStateMixin {
  //带光晕的球图片宽度
  double sizeOfBallWithFlare;

  static List<Point> points = [];
  static List<Point> lineStartList = [];
  static List<Point> lineEndtList = [];
  static List<Point> smallBallList = [];
  Animation<double> animation;
  AnimationController controller;

  double currentRadian = 0;

  //手指移动的上一个位置
  Offset lastPosition;

  //手指按下的位置
  Offset downPosition;

  //上次点击并命中关键词的时间
  int lastHitTime = 0;
  //当前的旋转轴
  Point axisVector = getAxisVector(Offset(2, -1));

  @override
  void initState() {
    super.initState();
    // ssd();
    //计算球尺寸、半径等
    sizeOfBallWithFlare = widget.mediaQueryData.size.width - 2 * 10.w;
    double sizeOfBall = sizeOfBallWithFlare * 32 / 35;
    radius = (sizeOfBall / 2).round();

    generatePoints([widget.keywords, widget.highlight, widget.lineList]);

    //动画
    controller = AnimationController(
        duration: Duration(milliseconds: 20000), vsync: this);
    animation = Tween(begin: 0.0, end: pi * 2).animate(controller);
    animation.addListener(() {
      setState(() {
        for (int i = 0; i < smallBallList.length; i++) {
          rotatePoint(
              axisVector, smallBallList[i], animation.value - currentRadian);
        }
        for (int i = 0; i < points.length; i++) {
          Point point = points[i];

          if (point.model.normName == "") {
            rotatePoint(axisVector, points[i], animation.value - currentRadian);
          } else {
            rotatePoint(axisVector, points[i], animation.value - currentRadian,
                isCore: true);
          }
        }
        currentRadian = animation.value;
      });
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        currentRadian = 0;

        controller.forward(from: 0.0);
      }
    });
    controller.forward();
  }

  @override
  void didUpdateWidget(XBallView oldWidget) {
    super.didUpdateWidget(oldWidget);

    //数据有变化，重新初始化点
    if (oldWidget.keywords != widget.keywords) {
      generatePoints([widget.keywords, widget.highlight, widget.lineList]);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  static generatePoints(
    List<List<UserLevelModel>> list,
  ) async {
    points.clear();
    lineStartList.clear();
    lineEndtList.clear();
    smallBallList.clear();

    List<UserLevelModel> keywords = list[0];
    List<UserLevelModel> highlight = list[1];
    List<UserLevelModel> lineList = list[2];

    Random random = Random();
    // 仰角基准值
    // 均匀分布仰角
    List<double> centers = [
      0.5,
      0.35,
      0.65,
      0.35,
      0.2,
      0.5,
      0.65,
      0.35,
      0.65,
      0.8,
    ];

    double width = (radius * 2 - 100 * 2) / highlight.length;
    //将2pi分为keywords.length等份;
    for (int i = 0; i < highlight.length; i++) {
      UserLevelModel model = highlight[i];

      //仰角
      double eAngle = (centers[i % 10] + (random.nextDouble() - 0.5) / 10) * pi;

      //球极坐标转为直角坐标
      double z = 0;
      double x = -radius + 100 + width * i;
      double y = radius * cos(eAngle);
      if (i == 0) {
        x = 50;
        y = sqrt(100 * 100 - 50 * 50) / 2;
      }

      if (i == 1) {
        x = -50;
        y = sqrt(100 * 100 - 50 * 50) / 2;
      }
      if (i == 2) {
        x = 0;
        y = -sqrt(100 * 100 - 50 * 50) / 2;
      }

      Point point = Point(x, y, z, model: model);

      point.name = model.normName;

      // 计算point在各个z坐标时的paragraph
      point.paragraphs = [];
      //每3个z生成一个paragraphs，节省内存
      for (int z = -radius; z <= radius; z += 3) {
        point.paragraphs.add(
          buildText(
            point.name,
            2.0 * radius,
            getFontSize(z.toDouble() + 30),
            getFontOpacity(model.lightLevel / 4),
            true,
          ),
        );
      }

      points.add(point);
    }

    // //将2pi分为keywords.length等份;
    double dAngleStep = 2 * pi / (keywords.length);
    for (int i = 0; i < keywords.length; i++) {
      UserLevelModel model = keywords[i];
      //极坐标方位角
      double dAngle = dAngleStep * i;
      //仰角
      double eAngle = (centers[i % 10] + (random.nextDouble() - 0.5) / 10) * pi;

      //球极坐标转为直角坐标

      double z = radius * sin(eAngle) * cos(dAngle);
      double x = radius * sin(eAngle) * sin(dAngle);
      double y = radius * cos(eAngle);

      Point point = Point(x, y, z, model: model);

      point.name = model.mofitName;
      //计算point在各个z坐标时的paragraph
      point.paragraphs = [];
      //每3个z生成一个paragraphs，节省内存
      for (int z = -radius; z <= radius; z += 3) {
        point.paragraphs.add(
          buildText(
            point.name,
            2.0 * radius,
            getFontSize(z.toDouble()),
            getFontOpacity(model.lightLevel / 4),
            false,
          ),
        );
      }

      points.add(point);
    }
//划线
    for (var j = 0; j < lineList.length; j++) {
      for (int i = 0; i < points.length; i++) {
        Point point = points[i];
        UserLevelModel model = point.model;

        UserLevelModel lineModel = lineList[j];
        if (model.normId == lineModel.normId) {
          lineStartList.add(point);
        }
        if (model.mofitId == lineModel.mofitId) {
          lineEndtList.add(point);
        }
      }
    }
// 均分100份
    double dAngle100 = 2 * pi / 300;
    for (int i = 0; i < 300; i++) {
      UserLevelModel model = UserLevelModel();
      //极坐标方位角
      double dAngle = dAngle100 * i;
      //仰角
      double eAngle = (centers[i % 10] + (random.nextDouble() - 0.5) / 10) * pi;

      //球极坐标转为直角坐标

      double z = radius * sin(eAngle) * cos(dAngle);
      double x = radius * sin(eAngle) * sin(dAngle);
      double y = radius * cos(eAngle);

      Point point = Point(x, y, z, model: model);

      point.name = '1';

      smallBallList.add(point);
    }

    return keywords;
  }

  ///检查此关键字是否需要高亮
  bool _needHight(String keyword) {
    return widget.highlight.any((element) => (element == keyword));
    bool ret = false;
    if (widget.highlight != null && widget.highlight.length > 0) {
      for (int i = 0; i < widget.highlight.length; i++) {
        if (keyword == widget.highlight[i]) {
          ret = true;
          break;
        }
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.screenWidth,
      height: ScreenUtil.screenHeight - ScreenUtil.statusBarHeight - 110 - 30,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/3d_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _buildBall(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBall() {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        int now = DateTime.now().millisecondsSinceEpoch;
        downPosition = convertCoordinate(event.localPosition);
        lastPosition = convertCoordinate(event.localPosition);

        //速度跟踪队列
        clearQueue();
        addToQueue(PositionWithTime(downPosition, now));

        //手指触摸时停止动画
        controller.stop();
      },
      onPointerMove: (PointerMoveEvent event) {
        int now = DateTime.now().millisecondsSinceEpoch;
        Offset currentPostion = convertCoordinate(event.localPosition);

        addToQueue(PositionWithTime(currentPostion, now));

        Offset delta = Offset(currentPostion.dx - lastPosition.dx,
            currentPostion.dy - lastPosition.dy);
        double distance = sqrt(delta.dx * delta.dx + delta.dy * delta.dy);
        //若计算量级太小，框架内部会报精度溢出的错误
        if (distance > 2) {
          //旋转点
          setState(() {
            lastPosition = currentPostion;

            //球体应该旋转的弧度角度 = 距离/radius
            double radian = distance / radius;
            //旋转轴
            axisVector = getAxisVector(delta);
            //更新点的位置
            for (int i = 0; i < points.length; i++) {
              Point point = points[i];
              if (point.model.normId == "") {
                rotatePoint(axisVector, points[i], radian);
              } else {
                rotatePoint(
                    axisVector, points[i], animation.value - currentRadian,
                    isCore: true);
              }
            }
            for (int i = 0; i < smallBallList.length; i++) {
              rotatePoint(axisVector, smallBallList[i], radian);
            }
          });
        }
      },
      onPointerUp: (PointerUpEvent event) {
        int now = DateTime.now().millisecondsSinceEpoch;
        Offset upPosition = convertCoordinate(event.localPosition);

        addToQueue(PositionWithTime(upPosition, now));

        //检测是否是fling手势
        Offset velocity = getVelocity();
        //速度模量>=1就认为是fling手势
        if (sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy) >= 1) {
          //开始fling动画
          currentRadian = 0;
          controller.fling();
        } else {
          //开始匀速动画
          currentRadian = 0;
          controller.forward(from: 0.0);
        }

        //检测点击事件
        double distanceSinceDown = sqrt(
            pow(upPosition.dx - downPosition.dx, 2) +
                pow(upPosition.dy - downPosition.dy, 2));
        //按下和抬起点的距离小于4，认为是点击事件
        if (distanceSinceDown < 4) {
          //寻找命中的point
          int searchRadiusW = 30;
          int searchRadiusH = 10;
          for (int i = 0; i < points.length; i++) {
            Point model = points[i];

            //points[i].z >= 0：只在球正面的点中寻找
            if (points[i].z >= 0 &&
                (upPosition.dx - points[i].x).abs() < searchRadiusW &&
                (upPosition.dy - points[i].y).abs() < searchRadiusH) {
              int now = DateTime.now().millisecondsSinceEpoch;
              //防止双击
              if (now - lastHitTime > 2000) {
                lastHitTime = now;

                //创建点选中动画序列
                pointAnimationSequence = PointAnimationSequence(
                    points[i], model.model.normId == "" ? false : true);

                //跳转页面
                Future.delayed(Duration(milliseconds: 500), () {
                  print("点击“${points[i].name}”");
                });
              }
              break;
            }
          }
        }
      },
      onPointerCancel: (_) {
        //开始匀速动画
        currentRadian = 0;
        controller.forward(from: 0.0);
      },
      child: Container(
        child: CustomPaint(
          size: Size(2.0 * radius, 2.0 * radius),
          painter:
              MyPainter(points, lineStartList, lineEndtList, smallBallList),
        ),
      ),
    );
  }

  ///速度跟踪队列
  Queue<PositionWithTime> queue = Queue();

  ///添加跟踪点
  void addToQueue(PositionWithTime p) {
    int lengthOfQueue = 5;
    if (queue.length >= lengthOfQueue) {
      queue.removeFirst();
    }

    queue.add(p);
  }

  ///清空队列
  void clearQueue() {
    queue.clear();
  }

  ///计算速度
  ///速度单位：像素/毫秒
  Offset getVelocity() {
    Offset ret = Offset.zero;

    if (queue.length >= 2) {
      PositionWithTime first = queue.first;
      PositionWithTime last = queue.last;
      ret = Offset(
        (last.position.dx - first.position.dx) / (last.time - first.time),
        (last.position.dy - first.position.dy) / (last.time - first.time),
      );
    }

    return ret;
  }
}

class MyPainter extends CustomPainter {
  List<Point> points;
  List<Point> startLine;
  List<Point> endLine;
  List<Point> smallBallList;
  Paint ballPaint;
  Paint pointPaint;
  Paint pointSmall;

  MyPainter(this.points, this.startLine, this.endLine, this.smallBallList) {
    //划线
    ballPaint = Paint()
      ..color = Colors.white.withOpacity(1 / 4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    pointPaint = Paint()..style = PaintingStyle.fill;
    pointSmall = Paint()
      ..color = Colors.white10.withOpacity(1 / 6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1)
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //绘制线
    if (startLine != null && endLine != null) {
      for (var i = 0; i < startLine.length; i++) {
        List<double> xy1 = transformCoordinate(startLine[i]);
        List<double> xy2 = transformCoordinate(endLine[i]);
        canvas.drawLine(Offset(xy1[0], xy1[1] + 18),
            Offset(xy2[0], xy2[1] + 18), ballPaint);
      }
    }

    //绘制文字
    for (int i = 0; i < points.length; i++) {
      Point point = points[i];
      UserLevelModel model = point.model;
      List<double> xy = transformCoordinate(points[i]);

      ui.Paragraph p;
      //是被选中的点，需要展示放大缩小效果
      if (pointAnimationSequence != null &&
          pointAnimationSequence.point == points[i]) {
        //动画未播放完毕
        if (pointAnimationSequence.paragraphs.isNotEmpty) {
          p = pointAnimationSequence.paragraphs.removeFirst();
          //动画已播放完毕
        } else {
          p = points[i].getParagraph(radius);
          pointAnimationSequence = null;
        }
      } else {
        p = points[i].getParagraph(radius);
      }

      //获得文字的宽高
      double halfWidth = p.minIntrinsicWidth / 2;
      double halfHeight = p.height / 2;
      //绘制文字（point中是3d模型坐标系中的坐标，需要转换为绘图坐标系中的坐标）
      canvas.drawParagraph(
        p,
        Offset(xy[0] - halfWidth, xy[1] - halfHeight),
      );

      canvas.drawCircle(
          Offset(
              xy[0],
              model.mofitName.length == 0
                  ? (xy[1] + halfHeight + 20.w)
                  : (xy[1] + halfHeight + 18.w)),
          model.mofitName.length == 0 ? 6 : 4,
          pointPaint
            ..color = model.normId == ""
                ? Colors.white.withOpacity(model.lightLevel / 4)
                : HexColor("FEFFD8").withOpacity(model.lightLevel / 4)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5));
    }

    //绘制小圆点
    for (var i = 0; i < smallBallList.length; i++) {
      Point point = smallBallList[i];
      //小原点
      // double op = 1 / 6 + Random().nextInt(3) / 40;
      List<double> xy = transformCoordinate(point);
      canvas.drawCircle(Offset(xy[0], xy[1]), 2, pointSmall);
    }
  }

  ///将3d模型坐标系中的坐标转换为绘图坐标系中的坐标
  ///x2 = r+x1;y2 = r-y1;
  List<double> transformCoordinate(Point point) {
    return [radius + point.x, radius - point.y, point.z];
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

///计算点point绕轴axis旋转radian弧度后的点坐标
///计算依据：罗德里格旋转矢量公式
void rotatePoint(Point axis, Point point, double radian,
    {bool isCore = false}) {
  double x = cos(radian) * point.x +
      (1 - cos(radian)) *
          (axis.x * point.x + axis.y * point.y + axis.z * point.z) *
          axis.x +
      sin(radian) * (axis.y * point.z - axis.z * point.y);

  double y = cos(radian) * point.y +
      (1 - cos(radian)) *
          (axis.x * point.x + axis.y * point.y + axis.z * point.z) *
          axis.y +
      sin(radian) * (axis.z * point.x - axis.x * point.z);

  double z;

  z = cos(radian) * point.z +
      (1 - cos(radian)) *
          (axis.x * point.x + axis.y * point.y + axis.z * point.z) *
          axis.z +
      sin(radian) * (axis.x * point.y - axis.y * point.x);
  if (isCore == true) {
    x = point.x;
    y = point.y;
    z = 0;
  }

  point.x = x;
  point.y = y;
  point.z = z;
}

///单位角度对应的圆弧长度：2*pi*r/2*pi = 1/r
double getRadian(double distance) {
  return distance / radius;
}

//将绘图坐标系中的坐标转换为3d模型坐标系中的坐标
Offset convertCoordinate(Offset offset) {
  return Offset(offset.dx - radius, radius - offset.dy);
}

///由旋转矢量得到旋转轴方向的单位矢量
///将旋转矢量(x,y)逆时针旋转90度即可
///x2 = xcos(pi/2)-ysin(pi/2)
///y2 = xsin(pi/2)+ycos(pi/2)
Point getAxisVector(Offset scrollVector) {
  double x = -scrollVector.dy;
  double y = scrollVector.dx;
  double module = sqrt(x * x + y * y);
  return Point(x / module, y / module, 0);
}

ui.Paragraph buildText(
  String content,
  double maxWidth,
  double fontSize,
  double opacity,
  bool highLight,
) {
  String text = content;
  //一行5个文字，最多两行，末尾显示...
  if (content.length > 5) {
    String firstLine = text.substring(0, 5);
    String secondLine = text.substring(5);
    if (secondLine.length > 5) {
      secondLine = secondLine.substring(0, 4) + "...";
    }
    text = "$firstLine\n$secondLine";
  }

  ui.ParagraphBuilder paragraphBuilder =
      ui.ParagraphBuilder(ui.ParagraphStyle());
  paragraphBuilder.pushStyle(
    ui.TextStyle(
        fontSize: fontSize,
        fontWeight: highLight ? FontWeight.w600 : FontWeight.normal,
        color: highLight
            ? HexColor("#12C0E1").withOpacity(opacity)
            : Colors.white.withOpacity(opacity),
        height: 1.0,
        shadows: [
          Shadow(
            color: HexColor("#12C0E1").withOpacity(opacity),
            offset: Offset(0, 0),
            blurRadius: 5,
          )
        ]),
  );
  paragraphBuilder.addText(text);

  ui.Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
  return paragraph;
}

double getFontSize(double z) {
  //点的z坐标为[-r,r]，对应文字的尺寸为[8,16]
  // return 8 + 8 * (100 + radius) / (2 * radius);
  return 8 + 10 * (z + radius) / (2 * radius);
}

double getFontOpacity(double z) {
  //点的z坐标为[-r,r]，对应点的透明度为[0.5,1]
  // return z;
  return z;
}

class Point {
  double x, y, z;
  String name;
  UserLevelModel model;

  List<ui.Paragraph> paragraphs;

  Point(this.x, this.y, this.z, {this.model});

  //z取值[-radius,radius]时的paragraph，依次存储在paragraphs中
  //每3个z生成一个paragraphs
  getParagraph(int radius) {
    int index = (z + radius).round() ~/ 3;
    return paragraphs[index];
  }
}

class PositionWithTime {
  Offset position;
  int time;

  PositionWithTime(this.position, this.time);
}

class PointAnimationSequence {
  Point point;
  bool needHighLight;
  Queue<ui.Paragraph> paragraphs;

  PointAnimationSequence(this.point, this.needHighLight) {
    paragraphs = Queue();

    double fontSize = needHighLight == true ? 20 : getFontSize(point.z);
    double opacity = getFontOpacity(point.model.lightLevel / 4);
    //字号从fontSize变化到22
    for (double fs = fontSize; fs <= 25; fs += 1) {
      paragraphs.addLast(
          buildText(point.name, 2.0 * radius, fs, opacity, needHighLight));
    }
    //字号从22变化到fontSize
    for (double fs = 22; fs >= fontSize; fs -= 1) {
      paragraphs.addLast(
          buildText(point.name, 2.0 * radius, fs, opacity, needHighLight));
    }
  }
}
