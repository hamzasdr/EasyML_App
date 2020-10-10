import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_textfield.dart';
import 'package:provider/provider.dart';

class UnloggedDialog extends StatefulWidget {
  @override
  _UnloggedDialogState createState() => _UnloggedDialogState();
}

class _UnloggedDialogState extends State<UnloggedDialog> with TickerProviderStateMixin{
  static const bool _LOGGING_IN = true, _REGISTERING = false;
  static const int _USERNAME_EXISTS = 1, _EMAIL_EXISTS = 2;
  bool _state = _LOGGING_IN;
  bool _loginFailed = false;
  int _registerState = 0;
  bool _registerPasswordsMatched = true;
  bool _loading = false;
  GlobalKey _key = GlobalKey();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  
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

  bool _passwordsMatch(){
    return (_state == _LOGGING_IN) || (_passwordController.text == _confirmPasswordController.text);
  }
  
  void _setPasswordsMatch() {
    setState(() => _registerPasswordsMatched = _passwordsMatch());
  }
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_setPasswordsMatch);
    _confirmPasswordController.addListener(_setPasswordsMatch);
  }
  
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 30),
        Text(
          _state == _LOGGING_IN
              ? "Login to your account"
              : "Register a new account",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait) ? MainAxisAlignment.center : MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                (MediaQuery.of(context).orientation == Orientation.portrait) ? FlatButton(
                  onPressed: _loading ? null : () {
                    setState(() {
                      _state = !_state;
                    });
                  },
                  child: Text(
                      _state == _LOGGING_IN
                          ? "Don't have an account? Register instead"
                          : "Already have an account? Login instead",
                      style: TextStyle(fontSize: 12)
                  ),
                ) : SizedBox(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery
                        .of(context)
                        .size
                        .height * 0.38 - calcBoxHeight(
                        screenHeight: MediaQuery
                            .of(context)
                            .size
                            .height,
                        context: _key.currentContext,
                        insetsHeight: MediaQuery
                            .of(context)
                            .viewInsets
                            .bottom
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
                          HelpTextField(
                            controller: _usernameController,
                            enableHelp: false,
                            name: "Username",
                            inputType: TextInputType.text,
                          ),
                          SizedBox(height: _state == _LOGGING_IN ? 0 : 10),
                          Builder(
                            builder: (BuildContext context) {
                              if (_state == _REGISTERING)
                                return HelpTextField(
                                  controller: _emailController,
                                  enableHelp: false,
                                  name: "Email",
                                  inputType: TextInputType.emailAddress,
                                );
                              else
                                return SizedBox(width: 0, height: 0);
                            },
                          ),
                          SizedBox(height: 10),
                          HelpTextField(
                            controller: _passwordController,
                            enableHelp: false,
                            name: "Password",
                            inputType: TextInputType.visiblePassword,
                            obscureText: true,
                          ),
                          SizedBox(height: _state == _LOGGING_IN ? 0 : 10),
                          Builder(
                            builder: (BuildContext context) {
                              if (_state == _REGISTERING)
                                return HelpTextField(
                                  controller: _confirmPasswordController,
                                  enableHelp: false,
                                  name: "Confirm Password",
                                  inputType: TextInputType.visiblePassword,
                                  obscureText: true,
                                );
                              else
                                return SizedBox(width: 0, height: 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _state == _REGISTERING && !_registerPasswordsMatched  ? Center(
                  child: Text(
                    "Passwords must match",
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                ) : SizedBox(),
                SizedBox(
                    height: calcBoxHeight(
                        screenHeight: MediaQuery
                            .of(context)
                            .size
                            .height,
                        context: _key.currentContext,
                        insetsHeight: MediaQuery
                            .of(context)
                            .viewInsets
                            .bottom
                    )
                ),
                SizedBox(height: 10),
                _state == _LOGGING_IN && _loginFailed ? Center(
                  child: Text(
                    "Invalid credintials",
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                ) : SizedBox(),
                _state == _REGISTERING && (_registerState == _USERNAME_EXISTS || _registerState == _EMAIL_EXISTS)  ? Center(
                  child: Text(
                    _registerState == _USERNAME_EXISTS ? "Username already exists" : "Email already exists",
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                  ),
                ) : SizedBox(),
                (MediaQuery.of(context).orientation == Orientation.portrait) ? FlatButton(
                  key: _key,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                  color: Colors.blueAccent,
                  disabledColor: Colors.grey,
                  onPressed: _loading || (_state == _REGISTERING && !_registerPasswordsMatched) ? null : () async {
                    if (_loading)
                      return;
                    if (_state == _LOGGING_IN) {
                      setState(() { _loading = true; });
                      try {
                        await userBloc.login(_usernameController.text, _passwordController.text);
                      } on LoginException catch (e) { // Login failed
                        setState(() {_loginFailed = true;});
                        setState(() {_loading = false;});
                      } on ServerCommunicationException catch (e) {
                        setState(() {_loading = false;});
                        Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) =>
                                InformationDialog(
                                  tag: 'comm_err',
                                  text: "Could not connect to server",
                                )
                        ));
                      }
                    }
                    else {
                      if(!_registerPasswordsMatched)
                        return;
                      setState(() {_loading = true;});
                      try {
                        await userBloc.register(_usernameController.text, _emailController.text, _passwordController.text);
                        print('success');
                        setState(() {
                          _registerState = 0;
                          _state = _LOGGING_IN;
                        });
                        Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) =>
                                InformationDialog(
                                  tag: 'comm_err',
                                  text: "Account created successfully!",
                                )
                        ));
                      } on UsernameAlreadyExistsException catch (e) { // Username exists
                        setState(() => _registerState = _USERNAME_EXISTS );
                      } on EmailAlreadyExistsException catch (e) { // Username exists
                        setState(() => _registerState = _EMAIL_EXISTS );
                      } on ServerCommunicationException catch (e) {
                        Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) =>
                                InformationDialog(
                                  tag: 'comm_err',
                                  text: "Could not connect to server",
                                )
                        ));
                      } finally {
                        setState(() { _loading = false; });
                      }
                    }
                  },
                  child:
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(tag: "comm_err", child: SizedBox()),
                      _loading ? SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          backgroundColor: Theme
                              .of(context)
                              .primaryColor,
                          strokeWidth: 1.5,
                        ),
                      ) : SizedBox(),
                      SizedBox(width: _loading ? 5 : 0,),
                      Text(_state == _LOGGING_IN ? "Login" : "Register", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),),
                    ],
                  ),
                ) : SizedBox(height: 20,),
              ],
            ),
            Column(
              children: [
                (MediaQuery.of(context).orientation == Orientation.landscape) ? FlatButton(
                  key: _key,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                  color: Colors.blueAccent,
                  disabledColor: Colors.grey,
                  onPressed: _loading || (_state == _REGISTERING && !_registerPasswordsMatched) ? null : () async {
                    if (_loading)
                      return;
                    if (_state == _LOGGING_IN) {
                      setState(() { _loading = true; });
                      try {
                        await userBloc.login(_usernameController.text, _passwordController.text);
                        setState(() {_loginFailed = false;});
                        Navigator.pop(context);
                      } on LoginException catch (e) { // Login failed
                        setState(() {_loginFailed = true;});
                      } on ServerCommunicationException catch (e) {
                        Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) =>
                                InformationDialog(
                                  tag: 'comm_err',
                                  text: "Could not connect to server",
                                )
                        ));
                      } finally {
                        setState(() {_loading = false;});
                      }
                    }
                    else {
                      if(!_registerPasswordsMatched)
                        return;
                      setState(() {_loading = true;});
                      try {
                        await userBloc.register(_usernameController.text, _emailController.text, _passwordController.text);
                        print('success');
                        setState(() {
                          _registerState = 0;
                          _state = _LOGGING_IN;
                        });
                        Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) =>
                                InformationDialog(
                                  tag: 'comm_err',
                                  text: "Account created successfully!",
                                )
                        ));
                      } on UsernameAlreadyExistsException catch (e) { // Username exists
                        setState(() => _registerState = _USERNAME_EXISTS );
                      } on EmailAlreadyExistsException catch (e) { // Username exists
                        setState(() => _registerState = _EMAIL_EXISTS );
                      } on ServerCommunicationException catch (e) {
                        Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) =>
                                InformationDialog(
                                  tag: 'comm_err',
                                  text: "Could not connect to server",
                                )
                        ));
                      } finally {
                        setState(() { _loading = false; });
                      }
                    }
                  },
                  child:
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(tag: "comm_err", child: SizedBox()),
                      _loading ? SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          backgroundColor: Theme
                              .of(context)
                              .primaryColor,
                          strokeWidth: 1.5,
                        ),
                      ) : SizedBox(),
                      SizedBox(width: _loading ? 5 : 0,),
                      Text(_state == _LOGGING_IN ? "Login" : "Register", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),),
                    ],
                  ),
                ) : SizedBox(),
                (MediaQuery.of(context).orientation == Orientation.landscape) ? FlatButton(
                  onPressed: _loading ? null : () {
                    setState(() {
                      _state = !_state;
                    });
                  },
                  child: Text(
                      _state == _LOGGING_IN
                          ? "Don't have an account?\nRegister instead"
                          : "Already have an account?\nLogin instead",
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                  ),
                ) : SizedBox(),
              ],
            )
          ],
        )

      ],
    );
  }
}
