import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/wrappers.dart';


class NumField extends StatefulWidget {

  static const INTEGER = 0, DOUBLE = 1;

  bool oldStyle;
  String name , desc,shortdesc;
  dynamic value;
  int type;
  Function setValue;
  TextEditingController controller;
  double defaultValue;
  bool checkable,enableHelp;
  String checkText;
  BooleanWrapper checkValue;
  NumField({
    this.name,
    this.value,
    this.type,
    this.setValue,
    this.desc,
    this.shortdesc,
    this.controller,
    this.defaultValue = 0,
    this.checkable = false,
    this.checkText = '',
    this.checkValue,
    this.oldStyle = false,
    this.enableHelp = true,
    Key key}): super(key: key);

  @override
  _NumFieldState createState() => _NumFieldState();
}

class _NumFieldState extends State<NumField> with TickerProviderStateMixin{

  TextEditingController field_value;// = new TextEditingController();

  bool _isExpanded = false;

  @override
  void initState() {
    widget.shortdesc == null && widget.oldStyle == true?
    setState(() {
      _isExpanded = true;
    }):
    setState(() {
      _isExpanded = false;
    });

    if(widget.controller == null){
      field_value = new TextEditingController();
      field_value.text = widget.value.toString();
    }
    else
      field_value = widget.controller;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    widget.checkValue = widget.checkValue ?? BooleanWrapper(initialValue: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 1,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 10000),
            child: widget.oldStyle ? Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AnimatedSize(
                          vsync: this,
                          duration: Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(left:0),
                            child:Container(
                              child: ListTile(
                                title: Text(widget.name, style: TextStyle(fontSize: 18,)),

                                subtitle: _isExpanded ?
                                GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        if(widget.shortdesc != null)
                                          _isExpanded = false;
                                      });
                                    },
                                  child: RichText(
                                        text:TextSpan(
                                        style: TextStyle(color: Colors.black54,fontSize: 13),
                                        text: "${widget.desc}..",
                                        children: [
                                          TextSpan(text:  widget.shortdesc != null ? "Show Less" : "",style:TextStyle(color: Colors.black,fontWeight: FontWeight.w600
                                          )),
                                        ]
                                        ),
                                        ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if(widget.shortdesc != null)
                                        _isExpanded = true;
                                    });
                                  },
                                  child: RichText(
                                        text:TextSpan(
                                          style: TextStyle(color: Colors.black54),
                                          text: "${widget.shortdesc}..",
                                        children: [
                                          TextSpan(text: "  More",style:TextStyle(color: Colors.black,fontWeight: FontWeight.w600
                                          )),
                                        ]
                                        ),
                                  ),
                                ),

                                isThreeLine: true,
                                trailing: Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right:10),
                                        child: widget.checkable ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                activeColor: Theme.of(context).primaryColor,
                                                value: widget.checkValue.value,
                                                onChanged: (_) {
                                                  setState(() {
                                                    widget.checkValue.value = !widget.checkValue.value;
                                                  });
                                                  if(widget.checkValue.value){
                                                    widget.value = null;
                                                  }
                                                  else{
                                                    widget.type == NumField.INTEGER ?
                                                    widget.value = int.tryParse(field_value.text)??widget.defaultValue.toInt():
                                                    widget.value = double.tryParse(field_value.text)??widget.defaultValue;
                                                  }
                                                  widget.setValue(widget.value);
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 60,
                                                child: Text(widget.checkText,
                                                  style: TextStyle(fontSize: 10),
                                                  textAlign: TextAlign.center,
                                                )
                                            )
                                          ],
                                        ) : SizedBox(),
                                      ),
                                      Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white
                                        ),
                                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                        child: TextField(
                                          enabled: !widget.checkValue.value,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          controller: widget.checkValue.value ? TextEditingController(text: '') : field_value,
//                                  obscureText: widget.obscureText,
                                          decoration:InputDecoration(
                                              fillColor: Colors.white,
                                              // contentPadding: EdgeInsets.all(10),
                                              isDense: true,
                                          ),

                                          onChanged: (String value){
                                              setState(() {
                                                if(field_value.text.isEmpty){
                                                    widget.value = widget.defaultValue;
                                                }
                                                else widget.type == NumField.INTEGER ?
                                                widget.value = int.tryParse(value)??widget.defaultValue.toInt():
                                                widget.value = double.tryParse(value)??widget.defaultValue;

                                                widget.setValue(widget.value);
                                              });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
//                    Divider(
//                      height: 5,
//                      // indent: 50,
//                      thickness: 1,
//                    ),
                      ],
                    ),
                  ),
                ),

              ],
            ):
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left:15),
                    child: Text(widget.name, style: TextStyle(fontSize: 18,)),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      widget.checkable ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              value: widget.checkValue.value,
                              onChanged: (_) {
                                setState(() {
                                  widget.checkValue.value = !widget.checkValue.value;
                                });
                                if(widget.checkValue.value){
                                  widget.value = null;
                                }
                                else{
                                  widget.type == NumField.INTEGER ?
                                  widget.value = int.tryParse(field_value.text)??widget.defaultValue.toInt():
                                  widget.value = double.tryParse(field_value.text)??widget.defaultValue;
                                }
                                widget.setValue(widget.value);
                              },
                            ),
                          ),
                          SizedBox(
                              width: 60,
                              child: Text(widget.checkText,
                                style: TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              )
                          )
                        ],
                      ) : SizedBox(),
                      Stack(
                        children: <Widget>[
                          AnimatedSize(
                            vsync: this,
                            duration: Duration(milliseconds: 150),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
//                                  height:45,
                                width:  widget.checkable ? MediaQuery.of(context).size.width * 1 - 136 : MediaQuery.of(context).size.width * 1 - 76,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: widget.checkValue.value ? Color(0xFFF8F8F8):Colors.white
                                ),
                                padding: EdgeInsets.fromLTRB(10, 8, 10, 5),
                                child: TextField(
                                  enabled: !widget.checkValue.value,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: widget.checkValue.value ? TextEditingController(text: '') : field_value,
//                                  obscureText: widget.obscureText,
                                  decoration:InputDecoration(
//                                      focusedBorder: InputBorder.none,
                                    helperMaxLines: 200,
                                    helperStyle: TextStyle(color: Color(0xFF808080)),
                                    helperText: _isExpanded ? "${widget.desc}" : null,
                                    hintText: widget.checkValue.value ? widget.checkText : null,
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(width: 0, style: _isExpanded ? BorderStyle.solid : BorderStyle.none)
                                    ),
//                                      border: InputBorder.none,
                                    fillColor: Colors.white,
                                    // contentPadding: EdgeInsets.all(10),
                                    isDense: true,
                                  ),

                                  onChanged: (String value){
                                    setState(() {
                                      if(field_value.text.isEmpty){
                                        widget.value = widget.defaultValue;
                                      }
                                      else widget.type == NumField.INTEGER ?
                                      widget.value = int.tryParse(value)??widget.defaultValue.toInt():
                                      widget.value = double.tryParse(value)??widget.defaultValue;

                                      widget.setValue(widget.value);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          widget.enableHelp ? Positioned(
                            top: 0,
                            right: 10,
                            child: IconButton(
                              iconSize: 28,
                              icon: Icon(_isExpanded ? Icons.help : Icons.help_outline),
                              color: Color(0xFF808080),
                              onPressed: (){
                                setState(() {
                                  print(_isExpanded);
                                  _isExpanded = !_isExpanded;
                                  print(_isExpanded);
                                });
//                  final dynamic tooltip = _key.currentState;
//                  tooltip.ensureTooltipVisible();
                              },
                            ),
                          ) : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
