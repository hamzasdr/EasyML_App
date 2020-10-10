import 'package:flutter/material.dart';

class HelpTextField extends StatefulWidget {
  String name, helperText;
  TextEditingController controller;
  bool enableHelp;
  TextInputType inputType;
  bool obscureText;
  double width;
  Function onChanged;
  HelpTextField({this.name, this.controller, this.enableHelp=true, this.inputType=TextInputType.number, this.obscureText=false,this.width=280,this.helperText="I'm some helpful text",this.onChanged});
  @override
  _HelpTextFieldState createState() => _HelpTextFieldState();
}

class _HelpTextFieldState extends State<HelpTextField> with TickerProviderStateMixin{
  bool _isExpanded = false;
  FocusNode _focus;
  Color _color = Color(0xFF808080);
  double _width = 1;
  @override
  void initState() {
    _focus = FocusNode();
    _focus.addListener((){
      if(_focus.hasFocus){
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
    });
    super.initState();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _key = new GlobalKey();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
//          width: MediaQuery.of(context).size.width * 0.65,
        width: widget.width,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 10000),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: _width, color: _color),

                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AnimatedSize(
                          vsync: this,
                          duration: Duration(milliseconds: 150),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: TextField(
                              focusNode: _focus,
                              keyboardType: widget.inputType,
                              controller: widget.controller,
                              obscureText: widget.obscureText,
                              onSubmitted: (String val){
                                if(val.indexOf('-') == 0){
                                  widget.controller.text = '1';
                                }
                                else if (val.indexOf('.') != -1){
                                  widget.controller.text = double.parse(val).ceil().toString();
                                }
                                widget.onChanged(val);
                              },
//                              onChanged: widget.onChanged,
                              decoration:InputDecoration(
                                  // labelText: widget.name,
                                  // hasFloatingPlaceholder: true,
                                  helperText: _isExpanded ? "${widget.helperText}\n" : null,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(width: 0, style: _isExpanded ? BorderStyle.solid : BorderStyle.none)
                                  ),
//                    border: OutlineInputBorder(
//                      borderRadius: BorderRadius.circular(15),
//                      borderSide: BorderSide(width: 10, style: BorderStyle.solid),
//                    ),
                                  fillColor: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.enableHelp ? Positioned(
                  top: 7.5,
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
                              style: TextStyle(fontSize: 14, color: _color),

                          )
                      ),
                    ) : SizedBox()
                )
//              Builder(
//                builder: (BuildContext context){
//                  if(widget.enableHelp)
//                    return Tooltip(
//                      key: _key,
//                      message: 'Hello there',
//                      textStyle: TextStyle(
//                        color: Colors.red,
//                        fontWeight: FontWeight.w600,
//                        fontSize: 16,
//                      ),
//                      decoration: BoxDecoration(
//                        color: Colors.white70,
//                        borderRadius: BorderRadius.circular(10),
//                      ),
//                      child: IconButton(
//                        iconSize: 28,
//                        icon: Icon(Icons.help_outline),
//                        onPressed: (){
//                          setState(() {
//                            _isExpanded = !_isExpanded;
//                          });
//                          final dynamic tooltip = _key.currentState;
//                          tooltip.ensureTooltipVisible();
//                        },
//                      ),
//                    );
//                  else
//                    return SizedBox(height: 0, width: 0);
//                },
//              ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
