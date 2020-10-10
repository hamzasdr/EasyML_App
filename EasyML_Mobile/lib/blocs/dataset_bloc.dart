import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:path/path.dart';
import 'package:prototyoe_project_app/network/http_service.dart';

class DataSetBloc extends ChangeNotifier{
  List<DataSet> _dataSets = [];
  Map<int, DataSet> _dataSetMap = {};
  List<DataSet> get dataSets => _dataSets;
  final FlutterUploader uploader = FlutterUploader();

  Completer<void> _loadingCompleter = Completer<void>();
  Box dataSetBox;
  DataSetBloc() : super(){
    Hive.openBox('datasets').then((box) async {
      dataSetBox = box;
      box.values.forEach((dataSetJson) {
        DataSet dataSet = DataSet.fromJson(jsonDecode(dataSetJson));
        addDataSet(dataSet);
      });
      _loadingCompleter.complete();
    });

  }

  Future<void> loadLocalDataSetsDone() {
    return _loadingCompleter.future;
  }

  void addDataSet(DataSet dataSet){
    _dataSets.add(dataSet);
    _dataSetMap[dataSet.id] = dataSet;
    notifyListeners();
  }

  Future persistDataSet (DataSet dataSet) async{
    await dataSetBox.add(jsonEncode(dataSet.toJson()));
    addDataSet(dataSet);
  }

  Future persistDataSetAt (DataSet dataSet) async {
    int index = _dataSets.indexOf(dataSet);
    if(index < 0)
      return;
    await dataSetBox.putAt(index, jsonEncode(dataSet.toJson()));
    notifyListeners();
  }

  Future deleteDataSet(DataSet dataSet) async {
    int index = _dataSets.indexOf(dataSet);
    if(index < 0)
      return;
    try {
      Response response = await HttpService.deleteDataSet(dataSet);
      if(response.statusCode == 204) { // No content
        _dataSetMap.remove(dataSet.id);
        _dataSets.removeAt(index);
        await dataSetBox.deleteAt(index);
        notifyListeners();
      }
    } on SocketException catch (e) {
      throw ServerCommunicationException();
    }
  }

  Future loadDataSets() async {
    await loadLocalDataSetsDone();
    Response response = await HttpService.getDataSets();
    if(response.statusCode == 200){
      print(response.body);
      List<dynamic> dataSetJson = jsonDecode(response.body);
      for(Map<String, dynamic> dataSet in dataSetJson){
        await addNetworkDataSet(DataSet.fromJson(dataSet));
      }
    }
  }

  Future getAllDataInformation() async {
    await Future.wait(
        _dataSets.map((dataSet)=>getDataInformation(dataSet.id))
    );
  }

  Future<DataSet> getDataInformation(int dataId) async {
    if(!_dataSetMap.containsKey(dataId)){
      return null;
    }
    try {
      Response response = await HttpService.getDataSetInfo(dataId);
      if(response.statusCode == 200){
        Map<String, dynamic> body = jsonDecode(response.body);
        _dataSetMap[dataId].info = body;
      }
      else{
        _dataSetMap[dataId].info = {};
      }
        persistDataSetAt(_dataSetMap[dataId]);
        return _dataSetMap[dataId];
    } on SocketException catch (e) {
      // throw ServerCommunicationException();
    }
    return null;
  }

  Future addNetworkDataSet(DataSet dataSet) async {
    if(_dataSetMap.containsKey(dataSet.id)){
      int index = _dataSets.indexOf(_dataSetMap[dataSet.id]);
      if(index >= 0) {
        _dataSetMap[dataSet.id] = dataSet;
        _dataSets[index] = dataSet;
        await persistDataSetAt(dataSet);
      }
      else{
        await persistDataSet(dataSet);
      }
    }
    else{
      await persistDataSet(dataSet);
    }
  }

  // removes the data set from local cache
  Future deleteDataSets() async {
    await dataSetBox.clear();
    _dataSets.clear();
    _dataSetMap.clear();
  }

  Future<DataSet> postNetworkDataSet(DataSet dataSet) async {
    try {
      Response response = await HttpService.postDataSet(dataSet);
      if(response.statusCode == 201) { // Created
        DataSet _dataSet = DataSet.fromJson(jsonDecode(response.body));
        dataSet.id = _dataSet.id;
        persistDataSet(dataSet);
        return dataSet;
      }
    } on SocketException catch (e) {
      throw ServerCommunicationException();
    }
    return null;
  }

  Future<DataSet> putNetworkDataSet(DataSet dataSet) async {
    try {
      Response response = await HttpService.putDataSet(dataSet);
      if(response.statusCode == 201) { // Created
        DataSet _dataSet = DataSet.fromJson(jsonDecode(response.body));
        _dataSetMap[dataSet.id] = _dataSet;
        _dataSets[_dataSets.indexOf(dataSet)] = _dataSet;
        await persistDataSetAt(_dataSet);
      }
    } on SocketException catch (e) {
      throw ServerCommunicationException();
    }
    return null;
  }

  Future<String> uploadDataSet(DataSet dataSet, String path) async {
    if(!_dataSetMap.containsKey(dataSet.id))
      return null;
    else{
      print(path);
      String taskId = await uploader.enqueueBinary(
          url: "${HttpService.uploadUrl}/${dataSet.type == 'json' ? 'json' : extension(path).substring(1).toLowerCase()}/${dataSet.id}",
          headers: HttpService.authorizationHeader,
          method: UploadMethod.POST,
          showNotification: false,
          file: FileItem(
            savedDir: dirname(path),
            filename: basename(path)
          )
      );
      return taskId;
    }
  }

  Future handleUploadDataSetResponse(DataSet dataSet, UploadTaskResponse response) async {
    int dataId = dataSet.id;
    if(response.statusCode == 200 || response.statusCode == 201){
      Map<String, dynamic> body = jsonDecode(response.response);
      if(body.containsKey('type'))
        body.remove('type');
      _dataSetMap[dataId].info = body;
    }
    else{
      _dataSetMap[dataId].info = {};
    }
    persistDataSetAt(_dataSetMap[dataId]);
  }
}