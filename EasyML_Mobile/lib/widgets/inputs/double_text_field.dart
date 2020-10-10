import 'dart:ui';

import 'package:flutter/material.dart';

class DoubleTextField extends StatefulWidget {
  String name, helperText;
  TextEditingController ctrl1, ctrl2;
  double width;
  IconData icon;
  bool enableHelp;
  DoubleTextField({this.ctrl1, this.ctrl2, this.width=280, this.name, this.helperText="I'm some helpful text", this.icon=Icons.clear, this.enableHelp=true});
  @override
  _DoubleTextFieldState createState() => _DoubleTextFieldState();
}

class _DoubleTextFieldState extends State<DoubleTextField> with TickerProviderStateMixin{
  bool _isExpanded = false;
  FocusNode _focus1, _focus2;
  Color _color = Color(0xFF808080);
  double _width = 1;


  @override
  void initState() {
    _focus1 = FocusNode();
    _focus2 = FocusNode();
    _focus1.addListener(handleFocus);
    _focus2.addListener(handleFocus);
    super.initState();
  }

  void handleFocus(){
    print("Testingggggg");
    if(_focus1.hasFocus || _focus2.hasFocus){
      setState(() {
        _color = Colors.black;
        _width = 2;
      });
    }
    else{
      setState(() {
        _color = Color(0xFF808080);
        _width = 1;
        _isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: _width, color:_color)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            focusNode: _focus1,
                            keyboardType: TextInputType.number,
                            controller: widget.ctrl1,
                            textDirection: TextDirection.rtl,
                            decoration:   InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(width: 0, style: BorderStyle.none)
                              ),
                                // hasFloatingPlaceholder: true,

//                      border: OutlineInputBorder(
//                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
//                          borderSide: BorderSide(width: 10, style: BorderStyle.solid)
//                      ),
                                fillColor: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 47.5,
                          child: VerticalDivider(
                            width: 25,
                            thickness: 1,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            focusNode: _focus2,
                            keyboardType: TextInputType.number,
                            controller: widget.ctrl2,
                            decoration:   InputDecoration(
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(width: 0, style: BorderStyle.none)
                                ),
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
//                        borderSide: BorderSide(width: 10, style: BorderStyle.solid),
//                      ),
                                fillColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      vsync: this,
                      duration: Duration(milliseconds: 150),
                      child: _isExpanded ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(
                            height: _width > 1.25 ? _width : 1.25,
                            thickness: _width > 1.25 ? _width : 1.25,
                            color: _color,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "${widget.helperText}\n",
                              style: TextStyle(color: Color(0x8A000000), fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ) : SizedBox(width: widget.width),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            child: Container(
              color: Color(0xFFF0F0F0),
              child: Icon(widget.icon, size: 24, color: _color,),
            ),
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
              child: widget.name != null ? Container(
                color: Theme.of(context).accentColor,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.5),
                    child: Text(
                      widget.name,
                      style: TextStyle(fontSize: 12, color: _color),

                    )
                ),
              ) : SizedBox()
          )
//          Positioned(
//            right: 10,
//            top: 17.5,
//            child: Tooltip(
//              key: null,
//              message: 'Hey',
//              textStyle: TextStyle(
//                color: Colors.red,
//                fontWeight: FontWeight.w600,
//                fontSize: 16,
//              ),
//              decoration: BoxDecoration(
//                color: Colors.white70,
//                borderRadius: BorderRadius.circular(10),
//              ),
//              child: GestureDetector(
//                child: Icon(Icons.help_outline,size: 28,
//                ),
//                onTap: (){
//                  // final dynamic tooltip = _key.currentState;
//                  // tooltip.ensureTooltipVisible();
//                },
//              ),
//            ),
//          ),
        ],
      ),
    );
  }
}
