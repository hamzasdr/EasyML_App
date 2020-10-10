import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:prototyoe_project_app/main.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class SwitchField extends StatefulWidget {
  String name,desc,shortdesc;
  BooleanWrapper booleanWrapper;
  Function onChanged;
  SwitchField({
    this.shortdesc,
    this.desc,
    this.name,
    this.onChanged,
    @required this.booleanWrapper
  });

  @override
  _SwitchFieldState createState() => _SwitchFieldState();
}

class _SwitchFieldState extends State<SwitchField> with TickerProviderStateMixin{

  bool _isExpanded;

  @override
  void initState() {
    widget.shortdesc == null ?
    setState(() {
      _isExpanded = true;
    }):
    setState(() {
      _isExpanded = false;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
//    final _key = new GlobalKey();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 1 ,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 10000),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left:5),
                        child: ListTile(
                          title: Text(widget.name, style: TextStyle(fontSize: 18,)),
                          subtitle:
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CupertinoSwitch(
                                        value: widget.booleanWrapper.value,
                                        onChanged: (bool value) {
                                          setState(() {
                                            widget.booleanWrapper.value = value;
                                          });
                                          if(widget.onChanged != null)
                                            widget.onChanged(value);
                                        },
                                        // activeColor: Color(0xFF808080),
                                      ),
                                      Text(
                                        widget.booleanWrapper.value ? '  Enabled' : '  Disabled',
                                        style: TextStyle(
                                          fontSize: 16
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 12.5),
                                    child: IconButton(
                                      icon: Icon(_isExpanded ? Icons.help : Icons.help_outline, size: 28, color: Color(0xFF808080),),
                                      onPressed: () => setState(()=>_isExpanded = (widget.shortdesc != null) && !_isExpanded),
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                vsync: this,
                                child: _isExpanded ? Text(
                                    widget.desc,
                                    style: TextStyle(color: Colors.black54,fontSize: 13),
                                ) : SizedBox(),
                              )
                            ],
                          ),
                          // isThreeLine: _isExpanded,
//                              trailing: Padding(
//                                padding: const EdgeInsets.only(top:0,right:12.5),
//                                child: Row(
//                                  mainAxisSize: MainAxisSize.min,
//                                  children: <Widget>[
//
//                                  ],
//                                ),
//                              ),
                        ),
                      ),
//                      Divider(
//                        height: 5,
//                        // indent: 50,
//                        thickness: 1,
//                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}
