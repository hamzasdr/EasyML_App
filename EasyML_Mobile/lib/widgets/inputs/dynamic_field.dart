import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:prototyoe_project_app/main.dart';
import 'package:prototyoe_project_app/wrappers.dart';
import './help_dropdown.dart';

class DynamicField extends StatefulWidget {
  double width;
  String name,desc,shortdesc;
  Function setValue;
  List<String> values;
  String defval;
  bool oldStyle,enableHelp;
  DropDownSelectionWrapper wrapper;
  TextEditingController controller;
  DynamicField({
    this.shortdesc,
    this.desc,
    this.name,
    this.setValue,
    this.values,
    this.defval,
    this.width = 175,
    this.wrapper,
    this.controller,
    this.enableHelp = true,
    this.oldStyle = false,
    Key key}): super(key: key);

  @override
  _DynamicFieldState createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> with TickerProviderStateMixin{
  Color _color = Color(0xFF808080);
  Timer longPressTimer;
  TextEditingController field_value;
  DropDownSelectionWrapper _wrapper;

  bool _isExpanded = false;
  // String _value;

  @override
  void initState() {
    widget.shortdesc == null && widget.oldStyle == true ?
    setState(() {
      _isExpanded = true;
    }):
    setState(() {
      _isExpanded = false;
    });

    if(widget.controller == null){
      field_value = TextEditingController();
    }
    if(widget.wrapper == null){
      _wrapper = DropDownSelectionWrapper(
          items: []
      );
    }
    else
      _wrapper = widget.wrapper;
    // _value = widget.defval;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    children: <Widget>[
                      AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(left:0),
                          child: Container(
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
                                        TextSpan(text: "More",style:TextStyle(color: Colors.black,fontWeight: FontWeight.w600
                                        )),
                                      ]
                                  ),
                                ),
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: widget.width,
                                    decoration: BoxDecoration(
                                      // border: Border.all(width : 2, style: BorderStyle.solid,color:Colors.grey),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
//                                      border: Border.all(width: 1.5, color:Colors.black),
                                    ),
//                                height: 100,
                                    child : Row(
//    crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Stack(
                                            children: <Widget>[
                                              Positioned(
                                                left: 7.5,
                                                top: 15,
                                                child: Icon(Icons.arrow_drop_down, color: Colors.black),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Container(
//                width: MediaQuery.of(context).size.width * 0.65,
//                                                decoration: BoxDecoration(
//                                                  borderRadius: BorderRadius.circular(15),
//                                                  border: Border.all(width: 1, color: _color),
//                                                ),
                                                  width: widget.width,
//                                              height: 110,
//                                              decoration: BoxDecoration(
//                                                border: Border.all(width : 2, style: BorderStyle.solid,color:Colors.grey),
//                                                borderRadius: BorderRadius.circular(15),
//                                              ),

                                                  // height: 60,
                                                  child: AnimatedSize(
                                                    vsync: this,
                                                    duration: Duration(milliseconds: 150),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                      child: FormField(
                                                        builder: (FormFieldState state) {
                                                          return InputDecorator(
                                                            decoration: InputDecoration(
                                                              // labelText: widget.name,
                                                                helperText: null,
                                                                // hasFloatingPlaceholder: true,
                                                                border: UnderlineInputBorder(
                                                                    borderSide: BorderSide(width:0, style: BorderStyle.none)
                                                                )
                                                            ),
                                                            //                              isEmpty: _Optimizer == '_',
                                                            child: DropdownButtonHideUnderline(
                                                              child: DropdownButton(
                                                                isExpanded: true,
                                                                value: _wrapper.selectedItem.toString(),
                                                                isDense: true,
                                                                onChanged: (String newValue) {
                                                                  _wrapper.selectedIndex = _wrapper.items.indexOf(newValue);
                                                                  state.didChange(newValue);
                                                                  if(widget.setValue != null)
                                                                    widget.setValue(newValue);
                                                                },
                                                                iconSize: 0,
                                                                items: _wrapper.items.map((value) {
                                                                  return DropdownMenuItem(
                                                                    value: value.toString(),
                                                                    child: Center(
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(left: 20,bottom: 5),
                                                                        child: Text(value,textAlign: TextAlign.center, style: TextStyle(fontSize: 14),),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
//                                          Positioned(
//                                              top: 0,
//                                              left: 0,
//                                              child: widget.name != null ? Container(
//                                                color: Theme.of(context).accentColor,
//                                                child: Padding(
//                                                    padding: EdgeInsets.symmetric(horizontal: 12.5),
//                                                    child: Text(
//                                                      widget.name,
//                                                      style: TextStyle(fontSize: 12, color: _color),
//
//                                                    )
//                                                ),
//                                              ) : SizedBox()
//                                          )
                                            ],
                                          ),

                                        ]
                                    ),
                                  ),
                                ],
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

              ],
            ) :
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left:15),
                    child: Text(widget.name, style: TextStyle(fontSize: 18,)),
                  ),
                  SizedBox(height: 5,),
                  Row(
//    crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Container(
//                width: MediaQuery.of(context).size.width * 0.65,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white
//                        border: Border.all(width: 1, color: _color),
                                ),
//                                width: widget.width,
                                width: MediaQuery.of(context).size.width * 1 - 76,
                                // height: 60,
                                child: AnimatedSize(
                                  vsync: this,
                                  duration: Duration(milliseconds: 150),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: FormField(
                                      builder: (FormFieldState state) {
                                        return InputDecorator(
                                          decoration: InputDecoration(
                                            // labelText: widget.name,
                                              helperText: _isExpanded ? "${widget.desc}\n" : null,
                                              helperMaxLines: 200,
                                              // hasFloatingPlaceholder: true,
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(width: _isExpanded ? 1 : 0, style: BorderStyle.none)
                                              )
                                          ),
                                          //                              isEmpty: _Optimizer == '_',
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              isExpanded: true,
                                              value: _wrapper.selectedItem.toString(),
                                              isDense: true,
                                              onChanged: (String newValue) {
                                                _wrapper.selectedIndex = _wrapper.items.indexOf(newValue);
                                                state.didChange(newValue);
                                                if(widget.setValue != null)
                                                  widget.setValue(newValue);
                                              },
                                              iconSize: 0,
                                              items: _wrapper.items.map((value) {
                                                return DropdownMenuItem(
                                                  value: value.toString(),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 20,bottom: 5),
                                                      child: Text(value,textAlign: TextAlign.center, style: TextStyle(fontSize: 14),),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 7.5,
                              top: 15,
                              child: Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ),
                            widget.enableHelp ? Positioned(
                              top: 5,
                              right: 0,
                              child: IconButton(
                                iconSize: 28,
                                icon: Icon(_isExpanded ? Icons.help : Icons.help_outline),
                                color: _color,
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

                            Positioned(
                                top: 0,
                                left: 0,
                                child: widget.name != null ? SizedBox()
//                  Container(
//                    color: Theme.of(context).accentColor,
//                    child: Padding(
//                        padding: EdgeInsets.symmetric(horizontal: 12.5),
//                        child: Text(
//                          widget.name,
//                          style: TextStyle(fontSize: 14, color: _color),
//
//                        )
//                    ),
//                  )
                                    : SizedBox()
                            )
                          ],
                        ),

                      ]
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
