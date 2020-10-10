import 'package:flutter/material.dart';

class BooleanWrapper{
  bool value;
  BooleanWrapper({
    @required bool initialValue
  }){
    value = initialValue;
  }
}

class DropDownSelectionWrapper{
  int _selectedIndex = 0;
  List<dynamic> items;
  bool enableDefaultValue;
  String defaultValueText;
  DropDownSelectionWrapper({
    @required this.items,
    this.enableDefaultValue = false,
    this.defaultValueText = "None"
  });

  dynamic get selectedItem => selectedIndex >= 0 ? items[selectedIndex] : null;
  dynamic get selectedDropDownItem => dropDownItems[_selectedIndex];
  int get selectedIndex{
    if(enableDefaultValue)
      return _selectedIndex - 1;
    return _selectedIndex;
  }
  set selectedIndex(int selectedIndex) => this._selectedIndex = selectedIndex;

  List<dynamic> get dropDownItems{
    if(!enableDefaultValue)
      return items;
    return <dynamic>[defaultValueText] + items;
  }
}