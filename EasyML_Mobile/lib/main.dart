import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:prototyoe_project_app/models/user.dart';
import 'package:prototyoe_project_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'blocs/connection_bloc.dart';
import 'blocs/dataset_bloc.dart';
import 'blocs/model_bloc.dart';
import 'blocs/model_type_bloc.dart';
import 'blocs/user_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  FlutterDownloader.initialize(debug: true);
  final ConnectionBloc connectionBloc = ConnectionBloc();
  final ModelTypeBloc modelTypeBloc = ModelTypeBloc();
  final ModelBloc modelBloc = ModelBloc();
  final DataSetBloc dataSetBloc = DataSetBloc();
  final UserBloc userBloc = UserBloc(modelBloc: modelBloc, dataSetBloc: dataSetBloc);
  runApp(MyApp(connectionBloc, modelTypeBloc, modelBloc, userBloc, dataSetBloc));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final ConnectionBloc connectionBloc;
  final ModelTypeBloc modelTypeBloc;
  final ModelBloc modelBloc;
  final UserBloc userBloc;
  final DataSetBloc dataSetBloc;

  MyApp(this.connectionBloc, this.modelTypeBloc, this.modelBloc, this.userBloc, this.dataSetBloc);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectionBloc>.value(
            value: connectionBloc
        ),
        ChangeNotifierProvider<ModelTypeBloc>.value(
          value: modelTypeBloc,
        ),
        ChangeNotifierProvider<ModelBloc>.value(
          value: modelBloc,
        ),
        ChangeNotifierProvider<UserBloc>.value(
          value: userBloc,
        ),
        ChangeNotifierProvider<DataSetBloc>.value(
          value: dataSetBloc
        )
      ],
      child: MaterialApp(
        title: 'EasyML',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: Color(0xFFF0F0F0),
          primaryColor: Color(0xFF2F2F2F),
          scaffoldBackgroundColor: Color(0xFFF0F0F0)
        ),
        home: HomePage()
      ),
    );
  }
}
