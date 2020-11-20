/*
 * @Author: kcc
 * @Date: 2020-11-09 14:35:26
 * @LastEditTime: 2020-11-09 14:35:55
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /wx_calander_app/lib/pages/familyCloud/model/user_level_model.dart
 */
class UserLevelModel {
  String mofitId;
  String mofitName;
  String normId;
  String normName;
  int lightLevel;
  int isShow;

  UserLevelModel(
      {this.mofitId,
      this.mofitName,
      this.normId,
      this.normName,
      this.lightLevel,
      this.isShow});

  UserLevelModel.fromJson(Map<String, dynamic> json) {
    mofitId = json['mofitId'];
    mofitName = json['mofitName'];
    normId = json['normId'];
    normName = json['normName'];
    lightLevel = json['lightLevel'];
    isShow = json['isShow'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mofitId'] = this.mofitId;
    data['mofitName'] = this.mofitName;
    data['normId'] = this.normId;
    data['normName'] = this.normName;
    data['lightLevel'] = this.lightLevel;
    data['isShow'] = this.isShow;
    return data;
  }
}
