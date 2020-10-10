import 'package:flutter/material.dart';
import 'dart:async';

class AddMultiFields extends StatefulWidget {
  String name, helperText,desc;
  TextEditingController controller;
  bool enableHelp;
  TextInputType inputType;
  bool obscureText;
  double width;
  Function onAdd;
  AddMultiFields({this.desc,this.name, this.controller, this.enableHelp=true, this.inputType=TextInputType.number, this.obscureText=false,this.width=280,this.helperText="I'm some helpful text",this.onAdd});
  @override
  _HelpMultiFieldState createState() => _HelpMultiFieldState();
}

class _HelpMultiFieldState extends State<AddMultiFields> with TickerProviderStateMixin{
//  bool _isExpanded = false;
//  FocusNode _focus;
//  Color _color = Color(0xFF808080);
//  double _width = 1;

  @override
  void initState() {
//    _focus = FocusNode();
//    _focus.addListener((){
//      if(_focus.hasFocus){
//        setState(() {
//          _color = Colors.black;
//          _width = 2;
//        });
//      }
//      else{
//        setState(() {
//          _color = Color(0xFF808080);
//          _width = 1;
//          _isExpanded = false;
//        });
//      }
//    });

    super.initState();
  }

  @override
  void dispose() {
//    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 1,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:8),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:0),
                      child: Container(
//                      decoration: BoxDecoration(
//                        border: Border.all(width : 1, style: BorderStyle.solid,),
//                        borderRadius: BorderRadius.circular(15),
//                      ),

                        child: ListTile(
                          title: Text(widget.name, style: TextStyle(fontSize: 18,)),
                          subtitle: Text(widget.desc,
                              style: TextStyle(fontSize: 13)),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Container(
                                  width: 125,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                  ),
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: TextField(
//                                    focusNode: _focus,
                                    textAlign: TextAlign.center,
                                    keyboardType: widget.inputType,
                                    controller: widget.controller,
                                    obscureText: widget.obscureText,
                                    decoration:InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(10, 12.5, 10, 2.5),
                                      isDense: true,
                                      // labelText: widget.name,
                                      // hasFloatingPlaceholder: true,
//                                      helperText: _isExpanded ? "${widget.helperText}\n" : null,
//                                      border: UnderlineInputBorder(
//                                          borderSide: BorderSide(width: 0, style: _isExpanded ? BorderStyle.solid : BorderStyle.none)
//                                      ),

                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                      ),
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (String val){
                                      setState(() {

                                      });
                                    },
                                  ),
                                ),
                              ),
//                              widget.controller.text.isNotEmpty?IconButton(
////                  iconSize: 28,
//                                icon: Icon(Icons.add_circle),
//                                onPressed: (){
//                                  setState(() {
//                                    if(widget.controller.text.isNotEmpty){
//                                      int value = int.parse(widget.controller.text);
//                                      widget.onAdd(value);
//                                    }
//
//                                  });
//                                  widget.controller.clear();
//                                },
//                              ):new Container(height: 0.0,),
                            ],

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
              Positioned(
                top: 15,
                right: 37.5,
                child: IconButton(
//                  iconSize: 28,
                  icon: Icon(Icons.add_circle, size: 28, color: widget.controller.text.isNotEmpty?Colors.black:Colors.grey,),
                  onPressed: (){
                    setState(() {
                      if(widget.controller.text.isNotEmpty){
                        int value = int.tryParse(widget.controller.text) ?? 0;
                        if(value > 0)
                          widget.onAdd(value);
                      }

                    });
                    widget.controller.clear();
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

}
