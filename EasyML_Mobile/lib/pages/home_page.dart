
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prototyoe_project_app/blocs/connection_bloc.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/network/http_service.dart';
import 'package:prototyoe_project_app/widgets/carousels/dataset_carousel.dart';
import 'package:prototyoe_project_app/widgets/carousels/model_carousel.dart';
import 'package:prototyoe_project_app/widgets/profile_avatar_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);
    Provider.of<ModelBloc>(context).context = context;
    ConnectionBloc connectionBloc = Provider.of<ConnectionBloc>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar:
        PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 30, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
//                    Icon(Icons.home, size: 30, color: Theme.of(context).accentColor),

                      Image.asset('assets/images/easyml.png'),
                      SizedBox(width: 5),
                      Text('EasyML', style: TextStyle(color: Theme.of(context).accentColor, fontSize: 24, fontWeight: FontWeight.w600),),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      userBloc.user == null ? SizedBox() :
                      connectionBloc.isDeviceConnected ? SizedBox():
                      SizedBox(
                        width: 120,
                          child: Text('Could not connect to server',
                              style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
                              textAlign: TextAlign.center,
                          )
                      ),
                      userBloc.user == null ? SizedBox() :
                      connectionBloc.isDeviceConnected ? SizedBox():
                      Icon(Icons.signal_wifi_off, color: Theme.of(context).accentColor,),
                      SizedBox(
                        width: userBloc.user == null || connectionBloc.isDeviceConnected ? 0 : 10
                      ),
                      Hero(
                          tag: "profile",
                          child: ProfileAvatar()
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
//      AppBar(
//        bottom: PreferredSize(
//          preferredSize: Size.fromHeight(20),
//          child: Text("Testing"),
//        ),
//        title:
////        Icon(Icons.home, size: 30),
//          Text('EasyML', style: TextStyle(color: Theme.of(context).accentColor, fontSize: 24),),
//        backgroundColor: Theme.of(context).primaryColor,
//        elevation: 0,
////        centerTitle: true,
//        actions: <Widget>[
//          Container(
////            color: Colors.green,
//            width: 55,
//            child: Padding(
//              padding: EdgeInsets.fromLTRB(10,10,10,10),
//              child: ProfileAvatar(),
//            ),
//          ),
//        ],
////          leading:
//
//      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
          color: Theme.of(context).accentColor,

        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
          child: RefreshIndicator(
            onRefresh: userBloc.reloadNetworkInfo,
            color: Theme.of(context).primaryColor,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 50),
                // CreateModelCarousel(),
//            SizedBox(height: 20),
                ModelCarousel(),
                DataSetCarousel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
