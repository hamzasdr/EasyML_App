import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class HelpDropDown extends StatefulWidget {
  DropDownSelectionWrapper dropDownSelectionWrapper;
  String name, helperText;
  double width;
  bool enableHelp;
  Function onChanged;
  bool isWhite;
  HelpDropDown({
    @required this.dropDownSelectionWrapper,
    this.name,
    this.onChanged,
    this.helperText = "helper text.",
    this.width = 280,
    this.enableHelp = true,
    this.isWhite = false,
  });

  @override
  _HelpDropDownState createState() => _HelpDropDownState();
}

class _HelpDropDownState extends State<HelpDropDown> with TickerProviderStateMixin{

  bool _isExpanded = false;
  Color _color = Color(0xFF808080);
//  List<String> activations = <String>['ReLU', 'Tanh', 'Sigmoid', 'Linear'];
  dynamic _value;
  @override
  void initState() {
    print("_value: $_value");
    _value = widget.dropDownSelectionWrapper.selectedDropDownItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
         widget.isWhite? Padding(
            padding: const EdgeInsets.only(left:15),
            child: Text(widget.name, style: TextStyle(fontSize: 18,)),
          ):SizedBox(),
          widget.isWhite?SizedBox(height: 5,):SizedBox(),
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
                            color: widget.isWhite ?  Colors.white: null,
                            border: widget.isWhite ? null: Border.all(width: 1.5, color: _color),
                        ),
                        width: widget.width,
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
                                      helperText: _isExpanded ? "${widget.helperText}\n" : null,
                                      helperMaxLines: 200,
                                      // hasFloatingPlaceholder: true,
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(width: _isExpanded ? 1 : 0, style: BorderStyle.none)
                                      )
                                  ),
                                  //                              isEmpty: _Optimizer == '_',
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<dynamic>(
                                      isExpanded: true,
                                      value: _value,
                                      isDense: true,
                                      onChanged: (dynamic newValue) {
                                        _value = newValue;
                                        _isExpanded = false;
                                        state.didChange(newValue);
                                        widget.dropDownSelectionWrapper.selectedIndex = widget.dropDownSelectionWrapper.dropDownItems.indexOf(newValue);
                                        print(widget.dropDownSelectionWrapper.selectedIndex);
                                        if(widget.onChanged != null)
                                          widget.onChanged(newValue);
                                      },
                                      iconSize: 0,
                                      items: widget.dropDownSelectionWrapper.dropDownItems.map((dynamic value) {
                                        // print(value.toString());
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(left: 25),
                                                child: Text(value.toString()),
                                              )
                                            ],
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
                        child: widget.name != null && !(widget.isWhite)?
                        Container(
                        color: Theme.of(context).accentColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.5),
                            child: Text(
                              widget.name,
                              style: TextStyle(fontSize: 14, color: _color),

                            )
                        ),
                      )
                            : SizedBox()
                    )
                  ],
                ),

              ]
          ),
        ],
      ),
    );
  }
}
