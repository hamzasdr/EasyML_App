import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:prototyoe_project_app/network/http_service.dart';

class ConnectionBloc extends ChangeNotifier{
  bool _isDeviceConnected = true;
  StreamSubscription _connectivitySubscription;
  StreamSubscription _dataConnectionSubscription;
  Timer serverCheckTimer;

  bool get isDeviceConnected => _isDeviceConnected;

  ConnectionBloc(){

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_checkConnectivityState);
    // _dataConnectionSubscription = DataConnectionChecker().onStatusChange.listen(_checkDataConnectionState);
    serverCheckTimer = Timer.periodic(Duration(seconds: 10), (timer){
      _checkServerConnection();
    });
  }

  Future _checkServerConnection() async {
    bool previousIsDeviceConnected = _isDeviceConnected;
    _isDeviceConnected = await HttpService.headApi();
    if(_isDeviceConnected != previousIsDeviceConnected)
      notifyListeners();
  }

//  void _checkDataConnectionState(DataConnectionStatus status) {
//    bool previousIsDeviceConnected = _isDeviceConnected;
//    _isDeviceConnected = (status == DataConnectionStatus.connected);
//    if(_isDeviceConnected != previousIsDeviceConnected)
//      notifyListeners();
//    print(DataConnectionChecker().lastTryResults);
//  }


  Future _checkConnectivityState(ConnectivityResult result) async {
    bool previousIsDeviceConnected = _isDeviceConnected;
    if(result == null)
      result = await Connectivity().checkConnectivity();
    if(result != ConnectivityResult.none) {
//      _isDeviceConnected = await DataConnectionChecker().hasConnection;
//      print(DataConnectionChecker().lastTryResults);
      _isDeviceConnected = await HttpService.headApi();
    }
    else
      _isDeviceConnected = false;

    if(_isDeviceConnected != previousIsDeviceConnected)
      notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
    _dataConnectionSubscription.cancel();
  }
}