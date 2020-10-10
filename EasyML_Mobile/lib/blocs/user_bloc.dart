import 'dart:convert';
import 'dart:io';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/user.dart';
import 'package:prototyoe_project_app/network/http_service.dart';
import 'package:path/path.dart';

import 'dataset_bloc.dart';
import 'model_bloc.dart';

class UserBloc extends ChangeNotifier{
  User _user;
  Box userBox;
  User get user => _user;
  ModelBloc modelBloc;
  DataSetBloc dataSetBloc;
  bool userNotificationEnabled = false;

  UserBloc({
    @required this.modelBloc,
    @required this.dataSetBloc
  }) : super(){
    Hive.openBox('user').then((box) async {
      userBox = box;
      String userJsonStr = box.get('user');
      if(userJsonStr == null)
        _user = null;
      else{
        _user = User.fromJson(jsonDecode(userJsonStr));
        HttpService.setToken(_user.token);
        await _afterUserLoaded();
//        await registerChannel();
//        await modelBloc.loadNetworkModels();
//        await dataSetBloc.loadDataSets();
//        _notify();
      }

    });
  }

  Future register(String username, String email, String password) async {
    await HttpService.register(username, email, password);
  }

  Future login(String username, String password) async {
    User user = await HttpService.login(username, password);
      if(user != null){
        _user = user;
        userBox.put('user', jsonEncode(_user.toJson()));
        await _afterUserLoaded();
      }
      else {
        throw LoginException();
      }
  }

  Future _afterUserLoaded() async {
    await Future.wait([registerChannel(), loadUserAvatar(), modelBloc.loadModels(), modelBloc.loadNetworkModels(), dataSetBloc.loadDataSets()]);
    await Future.wait([dataSetBloc.getAllDataInformation(), modelBloc.getAllModelInformation()]);
    notifyListeners();
  }

  Future reloadNetworkInfo() async {
    if(user == null)
      return;
    try {
      await Future.wait(
        [loadUserAvatar(), modelBloc.loadNetworkModels(), dataSetBloc.loadDataSets()]
      );
      await Future.wait(
        [
          modelBloc.getAllModelInformation(),
          dataSetBloc.getAllDataInformation()
        ]
      );

    } on SocketException catch (_) {}
    finally {
      notifyListeners();
    }
  }

  Future logout() async {
    await setNotifications(false);
    String channelId = await Airship.channelId;
    String deviceType = "";
    if(Platform.isAndroid)
      deviceType = "android";
    else if(Platform.isIOS)
      deviceType = "ios";
    HttpService.putDeviceInfoByChannelId(deviceType: deviceType, channelId: channelId, loggedIn: false);

    HttpService.setToken(null);
    _user = null;
    userBox.delete('user');
    await Future.wait([
      modelBloc.deleteNetworkModels(),
      dataSetBloc.deleteDataSets()
    ]);
    // TODO: Implement more actions before logout
    notifyListeners();
  }

  Future registerChannel() async {
    String channelId = await Airship.channelId;
    userNotificationEnabled = await Airship.userNotificationsEnabled;
    String deviceType = "";
    if(Platform.isAndroid)
      deviceType = "android";
    else if(Platform.isIOS)
      deviceType = "ios";
    Response response = await HttpService.postDeviceInfo(deviceType: deviceType, channelId: channelId, loggedIn: true);
    if(response.statusCode == 400) // Channel already exists
      response = await HttpService.putDeviceInfoByChannelId(deviceType: deviceType, channelId: channelId, loggedIn: true);
  }

  Future<bool> setNotifications(bool state) async {
    if(user == null)
      return false;
    bool value = await Airship.setUserNotificationsEnabled(state);
    userNotificationEnabled = state;
    notifyListeners();
    return value;
  }

  Future loadUserAvatar() async {
    Response userResponse = await HttpService.getUser();
    if(userResponse.statusCode == 200){
      _user.avatar = jsonDecode(userResponse.body)[0]['avatar'];
      await userBox.put('user', jsonEncode(_user.toJson()));
      notifyListeners();
    }
  }

  Future<String> uploadUserAvatar(String path) async {
    print(path);
    String taskId = await FlutterUploader().enqueue(
        url: HttpService.uploadAvatarUrl,
        headers: HttpService.authorizationHeader,
        method: UploadMethod.POST,
        showNotification: false,
        files: [
          FileItem(
              savedDir: dirname(path),
              filename: basename(path),
              fieldname: 'avatar'
          )
        ]
    );
    return taskId;
  }
}