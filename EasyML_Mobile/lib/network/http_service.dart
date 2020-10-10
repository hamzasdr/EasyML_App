import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/user.dart';
import 'dart:async';
import 'dart:convert';

class HttpService {
  static const String _ip = "http://192.168.1.95";
  static const String _server_ip = "$_ip:8000";
  static const String _ml_ip = "$_ip:5000";

  Model model;
  HttpService({this.model});

  static const String _apiUrl = "$_server_ip/api";
  static const String _registerUrl = "$_apiUrl/register";
  static const String _loginUrl = "$_apiUrl/login";
  static const String _userUrl = "$_apiUrl/user";
  static const String _trainUrl = "$_apiUrl/train";
  static const String _modelsUrl = "$_apiUrl/models";
  static const String _modelInfoUrl = "$_modelsUrl/info";
  static const String _dataUrl = "$_apiUrl/data";
  static const String _dataInfoUrl = "$_dataUrl/info";
  static const String _deviceUrl = "$_apiUrl/device";

  static const String _uploadAvatarUrl = "$_apiUrl/avatar/";
  static const String _uploadDataSetUrl = "$_ml_ip/upload";
  static const String _downloadModelUrl = "$_ml_ip/download/m";
  static const String _predictUrl = "$_ml_ip/predict";
  static const String _downloadPredictionUrl = "$_ml_ip/download/p";
  static String get uploadAvatarUrl => _uploadAvatarUrl;
  static String get uploadUrl => _uploadDataSetUrl;
  static String get downloadModelUrl => _downloadModelUrl;
  static String get predictUrl => _predictUrl;
  static String get downloadPredictionUrl => _downloadPredictionUrl;
  static Map<String, String> get authorizationHeader => {"Authorization": "Bearer $_token"};
  static String _token;

  // send a get request to the api, if it replies, then the server is up and running
  static Future<bool> headApi() async {
    try{
      await get(_apiUrl).timeout(Duration(seconds: 2));
      return true;
    }
    on SocketException catch (e){
      return false;
    }
    on TimeoutException catch (e){
      return false;
    }
  }

  // send a head request to the ML server, if it replies, then the server is up and running
  static Future<bool> headMl() async {
    try{
      await head(_ml_ip).timeout(Duration(seconds: 2));
      return true;
    }
    on SocketException catch (e){
      return false;
    }
  }

  static Future register(String username, String email, String password) async {
    try{
      Response response = await post(
          Uri.encodeFull("$_registerUrl/"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password
          })
      );
      if(response.statusCode == 201) // created
        return;
      Map<String, dynamic> body = jsonDecode(response.body);
      if(body.containsKey('username'))
        throw UsernameAlreadyExistsException();
      if(body.containsKey('email'))
        throw EmailAlreadyExistsException();
      throw ServerCommunicationException();
    }
    on SocketException catch(e){
      throw ServerCommunicationException();
    }
  }

  static Future<User> login(String username, String password) async {
    try {
      Response response = await post(
        Uri.encodeFull("$_loginUrl/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'username': username,
          'password': password
        })
      );
      if(response.statusCode == 200){ // ok
        Map<String, dynamic> json = jsonDecode(response.body);
        _token = json['token'];
        User user = User(
            id: 0,
            username: username,
            avatar: null,
            token: json['token']
        );
        return user;
      }
      throw LoginException();
    } on SocketException catch (e) {
      throw ServerCommunicationException();
    }
  }

  static void setToken(String token){
    _token = token;
  }

  static Future<Response> getUser(){
    return get(
      Uri.encodeFull("$_userUrl"),
      headers: HttpService.authorizationHeader
    );
  }

  static Future<Response> postModel(Model model) async{
        var body = json.encode(model.toJson());
        return post(
            Uri.encodeFull("$_modelsUrl/"),
            headers: {
              "Authorization": "Bearer $_token",
              "Content-Type": "application/json",
            },
            body: body
        );
}

  static Future<Response> getModels() async{
    return get(
      Uri.encodeFull(_modelsUrl),
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json"
      },
    );
  }

  static Future<Response> getModel(int id) async{
    return get(
      Uri.encodeFull("$_modelsUrl/$id/"),
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json"
      },
    );
  }

  static Future<Response> getModelInfo(int modelId) async {
    return get(
      Uri.encodeFull("$_modelInfoUrl/$modelId"),
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json"
      },
    );
  }

  static Future<Response> deleteModel(Model model) async {
    return delete(
      Uri.encodeFull("$_modelsUrl/${model.id}/"),
      headers: {
        "Authorization": "Bearer $_token",
      }
    );
  }

  static Future<Response> putModel(Model model) async {
    var body = jsonEncode(model.toJson());
    return put(
        Uri.encodeFull("$_modelsUrl/${model.id}/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json"},
        body: body
    );
  }

  static Future<Response> getData() async {
    return get(
      Uri.encodeFull(_modelsUrl),
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json"
      },
    );
  }

  static Future<Response> postDeviceInfo({
    @required String deviceType,
    @required String channelId,
    bool loggedIn = false
  }) async {
    return post(

        Uri.encodeFull("$_deviceUrl/"),
//            String tok = userBloc.user.token;
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'device_type': deviceType,
          'channel_id': channelId,
          'logged_in': loggedIn
        })
    );
  }

  static Future<Response> putDeviceInfo({
    @required int deviceId,
    @required String deviceType,
    @required String channelId,
    bool loggedIn = false
  }) async {
    return put(

        Uri.encodeFull("$_deviceUrl/$deviceId/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'device_type': deviceType,
          'channel_id': channelId,
          'logged_in': loggedIn
        })
    );
  }

  static Future<Response> getDeviceInfoByChannelId({
    @required String channelId,
  }) async {
    return get(

        Uri.encodeFull("$_deviceUrl/byid/$channelId"),
        headers: {
          "Authorization": "Bearer $_token",
          "Accept": "application/json",
        }

    );
  }

  static Future<Response> putDeviceInfoByChannelId({
    @required String deviceType,
    @required String channelId,
    bool loggedIn = false
  }) async {
    return put(

        Uri.encodeFull("$_deviceUrl/byid/$channelId/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'device_type': deviceType,
          'channel_id': channelId,
          'logged_in': loggedIn
        })
    );
  }
  static Future<Response> getDataSets() async {
    return get(
        Uri.encodeFull("$_dataUrl/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Accept": "application/json",
        }
    );
  }

  static Future<Response> postDataSet(DataSet dataSet) async {
    return post(
        Uri.encodeFull("$_dataUrl/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataSet.toJson())
    );
  }

  static Future<Response> putDataSet(DataSet dataSet) async {
    return put(
        Uri.encodeFull("$_dataUrl/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataSet.toJson())
    );
  }

  static Future<Response> deleteDataSet(DataSet dataSet) async {
    return delete(
        Uri.encodeFull("$_dataUrl/${dataSet.id}/"),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        }
    );
  }

  static Future<Response> getDataSetInfo(int dataId) async {
    return get(
      Uri.encodeFull("$_dataInfoUrl/$dataId"),
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json"
      },
    );
  }
  static Future<Response> trainModel(int modelId, int dataId, Map<String, dynamic> parameters) async{

    parameters['data'] = dataId;
    return post(
    Uri.encodeFull("$_trainUrl/$modelId/"),
      headers: {
        "Authorization": "Bearer $_token",
        "Content-Type": "application/json"},
      body: jsonEncode(parameters)
    );
  }

}

