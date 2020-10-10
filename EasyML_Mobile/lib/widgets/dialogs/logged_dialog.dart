import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/widgets/inputs/Upload_data_Field.dart';
import 'package:provider/provider.dart';

import '../hero_dialog_route.dart';
import 'info_dialog.dart';

class LoggedDialog extends StatefulWidget {
  Function update;

  LoggedDialog({
    this.update
  });
  @override
  _LoggedDialogState createState() => _LoggedDialogState();
}

class _LoggedDialogState extends State<LoggedDialog> with TickerProviderStateMixin{
//  static const bool LOGGING_IN = true, REGISTERING = false;
//  bool _status = LOGGING_IN;
  GlobalKey _key = GlobalKey();
  String _taskId;
//  TextEditingController _usernameController = TextEditingController();
//  TextEditingController _passwordController = TextEditingController();
//  TextEditingController _emailController = TextEditingController();
//  TextEditingController _confirmPasswordController = TextEditingController();
//
  double calcBoxHeight({double screenHeight, BuildContext context, double insetsHeight}){
//    print("Screen height $screenHeight");
//    if(context != null)
//      print("Element location ${(context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy}");
//    print("Insets height $insetsHeight");
    if(insetsHeight == 0 || context == null)
      return 0;
    double value = insetsHeight-(screenHeight-(context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy);

    if(value < 0)
      return 0;
//    print("Value $value");
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    if(userBloc.user == null)
      WidgetsBinding.instance.addPostFrameCallback((_)=>Navigator.pop(context));
    return Builder(
      builder: (BuildContext context){
        if(userBloc.user == null)
          return SizedBox(height: 0);
        else
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 35),
              Text("${userBloc.user.username}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height*0.65-calcBoxHeight(
                      screenHeight: MediaQuery.of(context).size.height,
                      context: _key.currentContext,
                      insetsHeight: MediaQuery.of(context).viewInsets.bottom
                  ),
                ),
                child: SingleChildScrollView(
                  child: AnimatedSize(
                    vsync: this,
                    duration: Duration(milliseconds: 150),
                    curve: Curves.decelerate,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Enable notifications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              CupertinoSwitch(
                                value: userBloc.userNotificationEnabled,
                                onChanged: (value) async {
                                  await userBloc.setNotifications(value);
                                  setState((){});
                                },
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                          child: UploadDataField(
                            type: FileType.image,
                            uploadButtonText: Text("Upload Avatar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),),
                            uploadButtonIcon: Icon(FontAwesomeIcons.image, color: Colors.white, size: 25,),
                            onUploadTapped: (path) async {
                              _taskId = await userBloc.uploadUserAvatar(path);
                              setState(() {});
                              return _taskId;
                            },
                            onUploadComplete: (UploadTaskResponse response) async {
                              if(response.status == UploadTaskStatus.failed)
                                if(response.statusCode != 201 && response.statusCode != 200){
                                  Navigator.push(context, HeroDialogRoute(
                                      builder: (BuildContext context) => InformationDialog(
                                        tag: 'dialog',
                                        text: "An error has occurred ☹",
                                      )
                                  ));
                                  return;
                                }
                                await userBloc.loadUserAvatar();
                                setState(() {});
                                if(widget.update != null)
                                  widget.update();
                            },
                          ),
                        ),
                        FlatButton(
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await userBloc.logout();
                          },
                          child: Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: calcBoxHeight(
                      screenHeight: MediaQuery.of(context).size.height,
                      context: _key.currentContext,
                      insetsHeight: MediaQuery.of(context).viewInsets.bottom
                  )
              ),
              SizedBox(height: 10),

            ],
          );
      },
    );
  }
}
