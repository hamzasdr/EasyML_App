

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/network/http_service.dart';
import 'package:prototyoe_project_app/pages/model_page.dart';
import 'package:prototyoe_project_app/pages/trained_model_page.dart';


class ModelBloc extends ChangeNotifier{
  List<Model> _models = [];
  List<Model> get models => _models;
  Map<int, Model> _syncedModels = {};
  Completer<void> _loadingCompleter = Completer<void>();
  List<String> downloadTasks = [];
  BuildContext _context;

  BuildContext get context => _context;
  set context(BuildContext context) => _context = _context ?? context;

  Box modelsBox;
  ModelBloc() : super(){
    Hive.openBox('models').then((box) async {
      modelsBox = box;
      box.values.forEach((modelJson) {
        Model model = Model.fromJson(jsonDecode(modelJson));
        addModel(model);
        // print(model.synced);
        if(model.id != null && model.id >= 0)
          _syncedModels[model.id] = model;
      });
      _loadingCompleter.complete();

      // Set up when push notification is received
      Airship.onPushReceived.listen((event) async {
        Map<String, dynamic> data = jsonDecode(event.payload['payload']);
        int id = data['id'];
        print(id);
        if(!_syncedModels.containsKey(id)){
          await Airship.clearNotification(event.notification.notificationId);
          return;
        }
        if(data['status'] == 'done' || data['status'] == 'fail'){

          _syncedModels[id].beingTrained = false;
          if(data['status'] == 'done'){
            _syncedModels[id].info = data;
          }
          await persistExistingModel(_syncedModels[id]);
          notify();
        }
      });

      Airship.onNotificationResponse.listen((event){
        Map<String, dynamic> data = jsonDecode(event.payload['str']);
        if(data['status'] == 'done' && _context != null){
          int id = data['id'];
          if(!_syncedModels.containsKey(id))
            return;
          Navigator.popUntil(_context, (route) => route.settings.name == '/');
          Navigator.push(_context, MaterialPageRoute(
            builder: (BuildContext context){
              return ModelPage(model: _syncedModels[id],);
            }
          ));
          Navigator.push(_context, MaterialPageRoute(
            builder: (BuildContext context){
              return TrainedModelPage(model: _syncedModels[id],);
            }
          ));
          notify();
        }
      });
    });
  }

  Future<void> loadModels(){
    return _loadingCompleter.future;
  }

  void notify(){
    notifyListeners();
  }

  void addModel(Model model){
    _models.add(model);
    notifyListeners();
  }

  void updateModel(Model model){
    for(int i = 0; i < _models.length; i++)
      if(_models[i].name == model.name)
        _models[i] = model;
    notifyListeners();
  }

  Future persistModel(Model model) async{
    for(Model mdl in _models){
      if(mdl.name == model.name)
        throw DuplicateNameException();
    }

    await modelsBox.add(jsonEncode(model.toJson()));
    _models.add(model);
    notifyListeners();
  }

  Future<Model> persistModelAt(Model model, int index) async {
    await modelsBox.putAt(index, jsonEncode(model.toJson()));
    _models[index] = model;
    if(model.id != null && model.id >= 0)
      _syncedModels[model.id] = model;
    notifyListeners();
    return model;
  }

  Future persistExistingModel(Model model) async{
    int index = _models.indexOf(model);
    if(index < 0){
      print('Not found');
      return;
    }

    await persistModelAt(model, index);
  }

  Future deleteModel(Model model) async {
    int index = _models.indexOf(model);
    if(index < 0)
      return;
    if(model.synced && model.id >= 0){
      try {
        await HttpService.deleteModel(model);
      } on SocketException catch (e) {
        throw ServerCommunicationException();
      }
      _syncedModels.remove(model.id);
    }
    await modelsBox.deleteAt(index);
    _models.removeAt(index);
    notifyListeners();
  }

  Future addNetworkModel(Model model) async {
    // print('${model.name} ${model.id}');
//    print('/////////////////////////////////////////////////////');
//    _syncedModels.forEach((key, value) {
//      print(value.toJson());
//    });
//    print('/////////////////////////////////////////////////////');
//    print(model.toJson());
    if(_syncedModels.containsKey(model.id)){
      int index = _models.indexOf(_syncedModels[model.id]);
      if(index >= 0) {
        if(_models[index].equals(model)){
          _models[index].synced = true;
        }
        else{
          _models[index].synced = false;
        }
        _models[index].beingTrained = model.beingTrained;
        await persistExistingModel(_models[index]);
      }
      else{
        // TODO: Handle duplicate name exception
        // Happens when user logs in and they have a local model named the same as a model at server
        Model existingModel;
        for(Model mdl in _models)
          if (mdl.name == model.name){
            existingModel = mdl;
            break;
          }
        if(existingModel != null){
          existingModel.name = existingModel.name + " (local)";
          await persistExistingModel(existingModel);
        }
        _syncedModels[model.id] = model;
        await persistModel(model);
      }
    }
    else{
      // TODO: Handle duplicate name exception
      // Happens when user logs in and they have a local model named the same as a model at server
      Model existingModel;
      for(Model mdl in _models)
        if (mdl.name == model.name){
          existingModel = mdl;
          break;
        }
      if(existingModel != null){
        existingModel.name = existingModel.name + " (local)";
        await persistExistingModel(existingModel);
      }
      _syncedModels[model.id] = model;
      await persistModel(model);
    }
  }

  Future<Model> getNetworkModel(int id) async {
    Response response = await HttpService.getModel(id);
    if(response.statusCode == 200){ // Ok
      return Model.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future postNetworkModel(Model model) async {
    try {
      Response response = await HttpService.postModel(model);
      if(response.statusCode == 201){ // Created
        Model returnedModel = Model.fromJson(jsonDecode(response.body));
        model.id = returnedModel.id;
        model.synced = true;
        persistExistingModel(model);

      } else {/* TODO: Raise error telling user that model couldn't be synced */}
    } on SocketException catch (e) {
      throw ServerCommunicationException();
    }
  }

  Future<Model> putNetworkModel(Model model) async {
    if(model.id != null && model.id >= 0){
      try{
        Response response = await HttpService.putModel(model);
        if(response.statusCode == 200)
          model.synced = true;
        return model;
      }
      on SocketException catch(e){
        throw ServerCommunicationException();
      }
    }
    else
      return null;
  }

  Future loadNetworkModels() async {
    await loadModels();
    Response response = await HttpService.getModels();
    if(response.statusCode == 200){
      List<dynamic> modelsJson = jsonDecode(response.body);
      await Future.wait(
          modelsJson.map((element) => addNetworkModel(Model.fromJson(element, synced: true)))
      );
    }
  }

  Future deleteNetworkModels() async {
    for(int i = 0; i < _models.length; i++){
      if(_models[i].synced){
        await modelsBox.deleteAt(i);
        _syncedModels.remove(_models[i].id);
        _models.removeAt(i);
        i--;
      }
    }
    notifyListeners();
  }

  Future getAllModelInformation() async {
    await Future.wait(
      _models.where((model)=>(model.id ?? -1)>=0).map((model) => getModelInformation(model))
    );
  }

  Future<Model> getModelInformation(Model model) async {
    if((model.id ?? -1) < 0)
      return null;
    try{
      Response response = await HttpService.getModelInfo(model.id);
      Map<String, dynamic> body;
      if (response.statusCode == 200) {
         body = jsonDecode(response.body);
      }
      _syncedModels[model.id].info = body ?? {};
      persistExistingModel(_syncedModels[model.id]);
      return _syncedModels[model.id];
    }
    on SocketException catch (e){
      // throw ServerCommunicationException();
    }
    return null;
  }

  Future<bool> trainModel(Model model, DataSet dataSet, Map<String, dynamic> parameters) async {
    if(_syncedModels[model.id] == null){
      print(model.id);
      return false;
    }
    try{
      Response response = await HttpService.trainModel(model.id, dataSet.id, parameters);
      if(response.statusCode == 202){ // Accepted
        _syncedModels[model.id].beingTrained = true;
        persistExistingModel(_syncedModels[model.id]);
        return true;
      }
      return false;
    }
    on SocketException catch(e){
      throw ServerCommunicationException();
    }
  }

  Future<String> downloadModel(Model model) async {
    String taskId = await FlutterDownloader.enqueue(
        url: "${HttpService.downloadModelUrl}/${model.id}",
        savedDir: (await getExternalStorageDirectory()).path,
        showNotification: false,
        openFileFromNotification: false,
        headers: HttpService.authorizationHeader,
        fileName: "${model.name}.pickle"
    );
    return taskId;
  }

  Future<String> uploadPredictionDataSet(Model model, String path) async {
    String taskId = await FlutterUploader().enqueueBinary(
        url: "${HttpService.predictUrl}/${model.id}",
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

  Future<String> downloadPrediction(Model model, String fileExtension) async {
    String taskId = await FlutterDownloader.enqueue(
        url: "${HttpService.downloadPredictionUrl}/${model.id}",
        savedDir: (await getExternalStorageDirectory()).path,
        showNotification: false,
        openFileFromNotification: false,
        headers: HttpService.authorizationHeader,
        fileName: "${model.name} prediction.$fileExtension"
    );
    return taskId;
  }
}