import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:prototyoe_project_app/main.dart';
import 'package:prototyoe_project_app/wrappers.dart';
import './help_dropdown.dart';
import './num_field.dart';

class MaxFeaturesField extends StatefulWidget {
  dynamic value;
  String name,desc,shortdesc;
  Function setValue;
  List<String> values;
  String defval;
  bool oldStyle,enableHelp;
  TextEditingController integerController, floatController;
  DropDownSelectionWrapper wrapper;
  MaxFeaturesField({
    this.shortdesc,
    this.desc,
    this.name = "Max Features",
    this.setValue,
    this.values,
    this.defval,
    this.value,
    @required this.integerController,
    @required this.floatController,
    this.wrapper,
    this.oldStyle = false,
    this.enableHelp = true,
  });

  @override
  _MaxFeaturesFieldState createState() => _MaxFeaturesFieldState();
}

class _MaxFeaturesFieldState extends State<MaxFeaturesField> with TickerProviderStateMixin{

  static const List<String> _maxFeaturesChoices = const <String>['auto','sqrt','log2','Integer','Float'];
  Color _color = Color(0xFF808080);
  Timer longPressTimer;
  FocusNode _largeDropdownFocusNode = FocusNode();
  FocusNode _smallDropdownFocusNode = FocusNode();
  // TextEditingController field_value;
//  bool int_flag = false;
//  bool float_flag = false;
  // String _value;
  bool _isExpanded = false;
  @override
  void initState() {

    widget.shortdesc == null && widget.oldStyle?
    setState(() {
      _isExpanded = true;
    }):
    setState(() {
      _isExpanded = false;
    });

//    widget.defval == 'Integer' ? int_flag = true : int_flag = false;
//    widget.defval == 'Float' ? float_flag = true : float_flag = false;
    // field_value.text = widget.value.toString();
    if(widget.wrapper == null){
      widget.wrapper = DropDownSelectionWrapper(
        items: _maxFeaturesChoices
      );
    }
    _smallDropdownFocusNode.addListener(() {
      print('eh');
      if(!_smallDropdownFocusNode.hasFocus)
        longPressTimer?.cancel();
    });
    _largeDropdownFocusNode.addListener(() {
      print('ehe');
      if(!_largeDropdownFocusNode.hasFocus)
        longPressTimer.cancel();
    });

    super.initState();
  }

  @override
  void dispose() {
    _smallDropdownFocusNode.dispose();
    _largeDropdownFocusNode.dispose();
    longPressTimer?.cancel();
    super.dispose();
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
            child: widget.oldStyle ?  Stack(
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
                            child: Container(

                              child: ListTile(

                                title: Text(widget.name, style: TextStyle(fontSize: 18,)),
                                subtitle:  _isExpanded ?
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
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
//                                        border: Border.all(width: 1.5, color:Colors.black),
                                        // border: Border.all(width: 1, color: _color),
                                        color: Colors.white,
                                      ),
                                      child : Row(
//    crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Stack(
                                              children: <Widget>[
                                                Positioned(
                                                  left: 0,
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
                                                    width: 200,
//                                              height: 110,
//                                              decoration: BoxDecoration(
//                                                border: Border.all(width : 2, style: BorderStyle.solid,color:Colors.grey),
//                                                borderRadius: BorderRadius.circular(15),
//                                              ),

                                                    // height: 60,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 0),
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
                                                                value: widget.wrapper.selectedItem.toString(),
                                                                isDense: true,
                                                                focusNode: _smallDropdownFocusNode,
                                                                onChanged: (String newValue) {
                                                                  longPressTimer?.cancel();
                                                                  widget.wrapper.selectedIndex = widget.wrapper.items.indexOf(newValue);
                                                                  state.didChange(newValue);
                                                                  if(widget.setValue != null)
                                                                    widget.setValue(newValue);
                                                                  if(widget.wrapper.selectedIndex == 3) { // int
                                                                    widget.setValue(int.tryParse(widget.integerController.text)??0);
                                                                  }
                                                                  else if(widget.wrapper.selectedIndex == 4) { // float
                                                                    widget.setValue(double.tryParse(widget.floatController.text)??0.0);
                                                                  }
                                                                },
                                                                iconSize: 0,
                                                                items: widget.wrapper.items.map((value) {
                                                                  return DropdownMenuItem(
                                                                    value: value.toString(),
                                                                    child: Padding(
                                                                      padding: EdgeInsets.only(right: 10.0),
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                        (widget.wrapper.items.indexOf(value) == 3 && widget.wrapper.selectedIndex == 3) ||
                                                                            (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                                        MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Padding(
                                                                            padding: EdgeInsets.only(left: 20,bottom: 5),
                                                                            child: Text(value,textAlign: TextAlign.center,style: TextStyle(fontSize: 14),),
                                                                          ),
                                                                          (widget.wrapper.items.indexOf(value) == 3 && widget.wrapper.selectedIndex == 3) ||
                                                                              (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ? Row(
                                                                            children: <Widget>[
                                                                              (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  longPressTimer?.cancel();
                                                                                  setState(() {
                                                                                    double value = max((double.tryParse(widget.floatController.text)??0.1)-0.1,0.0);
                                                                                    widget.floatController.text = value.toStringAsFixed(2);
                                                                                    widget.setValue(value);

                                                                                  });

                                                                                },
                                                                                onLongPress: () {
                                                                                  longPressTimer?.cancel();
                                                                                  longPressTimer = Timer.periodic(
                                                                                      Duration(milliseconds: 25), (timer) {
                                                                                    setState(() {
                                                                                      double value = max((double.tryParse(widget.floatController.text)??0.1)-0.1,0.0);
                                                                                      widget.floatController.text = value.toStringAsFixed(2);
                                                                                      widget.setValue(value);
                                                                                    });

                                                                                  });
                                                                                },
                                                                                onLongPressUp: () {
                                                                                  if (longPressTimer != null)
                                                                                    longPressTimer.cancel();
                                                                                },
                                                                                child: Icon(Icons.remove_circle,size: 25,),
                                                                              )
                                                                                  : SizedBox(),
                                                                               Container(
                                                                                  width: (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ? 40 : 70,
                                                                                  child: TextField(
                                                                                    textAlign: TextAlign.center,
                                                                                    keyboardType: TextInputType.number,
                                                                                    controller:
                                                                                    (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                                                    widget.floatController : widget.integerController,
                                                                                    decoration:InputDecoration(
                                                                                        fillColor: Colors.white
                                                                                    ),
                                                                                    onSubmitted: (String value){
                                                                                      setState(() {

                                                                                        if(widget.wrapper.selectedIndex == 3){
                                                                                          int value = max(int.tryParse(widget.integerController.text)??0, 0);
                                                                                          widget.integerController.text = value.toString();
                                                                                          widget.setValue(value);
                                                                                        }
                                                                                        else{
                                                                                          double value = max(double.tryParse(widget.floatController.text)??0.0, 0.0);
                                                                                          widget.floatController.text = value.toStringAsFixed(2);
                                                                                          widget.setValue(value);
                                                                                        }

                                                                                      });
                                                                                    },

                                                                                  )
                                                                              ),
                                                                              (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  longPressTimer?.cancel();
                                                                                  setState(() {
                                                                                    double value = max((double.tryParse(widget.floatController.text)??-0.1)+0.1,0.0);
                                                                                    value = double.parse(value.toStringAsFixed(1));
                                                                                    widget.floatController.text = value.toString();
                                                                                    widget.setValue(value);

                                                                                  });

                                                                                },
                                                                                onLongPress: () {
                                                                                  longPressTimer?.cancel();
                                                                                  longPressTimer = Timer.periodic(
                                                                                      Duration(milliseconds: 25), (timer) {
                                                                                    setState(() {
                                                                                      double value = max((double.tryParse(widget.floatController.text)??-0.1)+0.1,0.0);
                                                                                      widget.floatController.text = value.toStringAsFixed(2);
                                                                                      widget.setValue(value);
                                                                                    });

                                                                                  });
                                                                                },
                                                                                onLongPressUp: () {
                                                                                  if (longPressTimer != null)
                                                                                    longPressTimer.cancel();
                                                                                },
                                                                                child: Icon(Icons.add_circle,size: 25,),
                                                                              )
                                                                              : SizedBox(),
                                                                            ],
                                                                          ) : SizedBox()
                                                                        ],
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
                      ],
                    ),
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
                                              value: widget.wrapper.selectedItem.toString(),
                                              isDense: true,
                                              focusNode: _largeDropdownFocusNode,
                                              onChanged: (String newValue) {
                                                longPressTimer?.cancel();
                                                widget.wrapper.selectedIndex = widget.wrapper.items.indexOf(newValue);
                                                state.didChange(newValue);
                                                if(widget.setValue != null)
                                                  widget.setValue(newValue);
                                                if(widget.wrapper.selectedIndex == 3) { // int
                                                  widget.setValue(int.tryParse(widget.integerController.text)??0);
                                                }
                                                else if(widget.wrapper.selectedIndex == 4) { // float
                                                  widget.setValue(double.tryParse(widget.floatController.text)??0.0);
                                                }
                                              },
                                              iconSize: 0,
                                              items: widget.wrapper.items.map((value) {
                                                return DropdownMenuItem(
                                                  value: value.toString(),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 10.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
//                                                      (widget.wrapper.items.indexOf(value) == 3 && widget.wrapper.selectedIndex == 3) ||
//                                                          (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
//                                                      MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Padding(
                                                         padding:
                                                         (widget.wrapper.items.indexOf(value) == 3 && widget.wrapper.selectedIndex == 3) ||
                                                         (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4)?
                                                         EdgeInsets.only(left: 0,bottom: 5,right:25):EdgeInsets.only(left: 0,bottom: 5,right:0),
                                                          child: Text(value,textAlign: TextAlign.center,style: TextStyle(fontSize: 14),),
                                                        ),
                                                        (widget.wrapper.items.indexOf(value) == 3 && widget.wrapper.selectedIndex == 3) ||
                                                            (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ? Row(
                                                          children: <Widget>[
                                                            (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                            GestureDetector(
                                                              onTap: () {
                                                                longPressTimer?.cancel();
                                                                setState(() {
                                                                  double value = max((double.tryParse(widget.floatController.text)??0.1)-0.1,0.0);
                                                                  widget.floatController.text = value.toStringAsFixed(2);
                                                                  widget.setValue(value);

                                                                });

                                                              },
                                                              onLongPress: () {
                                                                longPressTimer?.cancel();
                                                                longPressTimer = Timer.periodic(
                                                                    Duration(milliseconds: 25), (timer) {
                                                                  setState(() {
                                                                    double value = max((double.tryParse(widget.floatController.text)??0.1)-0.1,0.0);
                                                                    widget.floatController.text = value.toStringAsFixed(2);
                                                                    widget.setValue(value);
                                                                  });

                                                                });
                                                              },
                                                              onLongPressUp: () {
                                                                if (longPressTimer != null)
                                                                  longPressTimer.cancel();
                                                              },
                                                              child: Icon(Icons.remove_circle,size: 25,),
                                                            )
                                                                : SizedBox(),
                                                            Container(
                                                                width: (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ? 75 : 100,
                                                                child: TextField(
                                                                  textAlign: TextAlign.center,
                                                                  keyboardType: TextInputType.number,
                                                                  controller:
                                                                  (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                                  widget.floatController : widget.integerController,
//                                  obscureText: widget.obscureText,
                                                                  decoration:InputDecoration(
                                                                      fillColor: Colors.white
                                                                  ),
                                                                  onSubmitted: (String value){
                                                                    setState(() {
                                                                      if(widget.wrapper.selectedIndex == 3){
                                                                        int value = max(int.tryParse(widget.integerController.text)??0, 0);
                                                                        widget.integerController.text = value.toString();
                                                                        widget.setValue(value);
                                                                      }
                                                                      else{
                                                                        double value = max(double.tryParse(widget.floatController.text)??0.0, 0.0);
                                                                        widget.floatController.text = value.toStringAsFixed(2);
                                                                        widget.setValue(value);
                                                                      }

                                                                    });
                                                                  },

                                                                )
                                                            ),
                                                            (widget.wrapper.items.indexOf(value) == 4 && widget.wrapper.selectedIndex == 4) ?
                                                            GestureDetector(
                                                              onTap: () {
                                                                longPressTimer?.cancel();
                                                                setState(() {
                                                                  double value = max((double.tryParse(widget.floatController.text)??-0.1)+0.1,0.0);
                                                                  widget.floatController.text = value.toStringAsFixed(2);
                                                                  widget.setValue(value);

                                                                });

                                                              },
                                                              onLongPress: () {
                                                                longPressTimer?.cancel();
                                                                longPressTimer = Timer.periodic(
                                                                    Duration(milliseconds: 25), (timer) {
                                                                  setState(() {
                                                                    double value = max((double.tryParse(widget.floatController.text)??-0.1)+0.1,0.0);
                                                                    widget.floatController.text = value.toStringAsFixed(2);
                                                                    widget.setValue(value);
                                                                  });

                                                                });
                                                              },
                                                              onLongPressUp: () {
                                                                if (longPressTimer != null)
                                                                  longPressTimer.cancel();
                                                              },
                                                              child: Icon(Icons.add_circle,size: 25,),
                                                            )
                                                                : SizedBox(),
                                                          ],
                                                        ) : SizedBox()
                                                      ],
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
