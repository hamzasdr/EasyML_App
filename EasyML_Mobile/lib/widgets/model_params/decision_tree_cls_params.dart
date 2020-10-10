import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/decision_tree_classifier_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/max_features_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class DecisionTreeClassifierParameters extends ParameterStatefulWidget {

  DecisionTreeClassifierParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _DecisionTreeClassifierParametersState createState() => _DecisionTreeClassifierParametersState();
}

class _DecisionTreeClassifierParametersState extends ParameterState<DecisionTreeClassifierParameters> {

  static const List<String> _maxFeaturesChoices = const <String>['auto', 'sqrt', 'log2', 'Number', 'Percentage'];
  static const List<String> _criterionChoices = const <String>['gini', 'entropy'];
  static const List<String> _splitterChoices = const <String>['best', 'random'];
  TextEditingController _maxFeaturesIntegerController = TextEditingController();
  TextEditingController _maxFeaturesFloatController = TextEditingController();

  TextEditingController _maxDepthController = TextEditingController(text: '1');
  BooleanWrapper _maxDepthNullWrapper = BooleanWrapper(initialValue: true);
  DropDownSelectionWrapper _maxFeaturesWrapper = DropDownSelectionWrapper(
    items: _maxFeaturesChoices
  );
  DropDownSelectionWrapper _criterionWrapper = DropDownSelectionWrapper(
    items: _criterionChoices
  );
  DropDownSelectionWrapper _splitterWrapper = DropDownSelectionWrapper(
    items: _splitterChoices
  );

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left:15),
              child: Text(
                'Model Parameters',
                style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 20,),
            NumField(
              controller: _maxDepthController,
              name:'Max Depth', type: NumField.INTEGER,
              checkable: true,
              checkText: 'As deep as possible',
              checkValue: _maxDepthNullWrapper,
              defaultValue: 1,
              shortdesc: "The maximum depth of the tree",
              desc: "\nThe maximum depth of the tree.\n"
                  "If set to as deep as possible, then nodes are expanded until all leaves are pure or until all leaves contain less than 2 samples.",
              setValue: (int newValue) {
              setState(() {
                (widget.stateModel as DecisionTreeClassifierModel).maxDepth = newValue;
                if(widget.onChanged != null)
                  widget.onChanged();
              });},
            ),

//            DynamicField(
//              wrapper: _maxFeaturesWrapper,
//              setValue: (String value){
//                if(_maxFeaturesWrapper.selectedIndex < 3) // not int or float
//                  (widget.stateModel as DecisionTreeClassifierModel).maxFeatures = value;
//                if(widget.onChanged != null)
//                  widget.onChanged();
//              },
//            ),
            MaxFeaturesField(
                wrapper: _maxFeaturesWrapper,
                integerController: _maxFeaturesIntegerController,
                floatController: _maxFeaturesFloatController,
                shortdesc: "The number of features to consider when looking for the best split.",
                desc: "\nThe number of features to consider when looking for the best split. \n\n"
                    "• If a number, then consider that number of features at each split.\n\n"
                    "• If a percentage, then that percentage of features (precentage × n_features) is considered at each split.\n\n"
                    "• If “auto”, then the number of max features = the number of features.\n\n"
                    "• If “sqrt”, then the number of max features = the square root of number of features.\n\n"
                    "• If “log2”, then the number of max features = the logarithm of number of features to the base of 2.",

                setValue: (dynamic newValue) {
                  setState(() {
                    if(newValue is double)
                      newValue /= 100.0;
                    (widget.stateModel as DecisionTreeClassifierModel).maxFeatures = newValue;
                  });
                  if(widget.onChanged != null)
                    widget.onChanged();
                  }
              ),
            SizedBox(height: 10),
          ],
        ),
        SizedBox(height: 15,),
        ExpansionTile(
          initiallyExpanded: false,
          trailing: Icon(null),
          leading: Icon(null),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Advanced Parameters',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                textAlign: TextAlign.justify,),
            ],
          ),
          subtitle: Icon(Icons.keyboard_arrow_down),
          children: <Widget>[
            Column(
              children: <Widget>[

                DynamicField(
                  wrapper: _criterionWrapper,
                    name:'Criterion',
                    shortdesc: "The function to measure the quality of a split.",
                    desc: "\nThe function to measure the quality of a split. "
                        "Supported criteria are: "
                        "\n\n• “gini” for the Gini impurity."
                        "\n\n• “entropy” for the information gain.",
                    setValue: (String newValue) {
                  setState(() {
//                          print(newValue);
                    (widget.stateModel as DecisionTreeClassifierModel).criterion = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                DynamicField(
                  wrapper: _splitterWrapper,
                    name: 'Splitter',
                    shortdesc: "The strategy used to choose the split at each node",
                    desc: "\nThe strategy used to choose the split at each node.Supported strategies are: \n\n* “best” to choose the best split.\n\n* “random” to choose the best random split.",
                    setValue: (String newValue) {
                  setState(() {
                    (widget.stateModel as DecisionTreeClassifierModel).splitter = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 5,),
      ],
    );
  }

  @override
  void update() {
    DecisionTreeClassifierModel _model = (widget.stateModel as DecisionTreeClassifierModel);

    if(_model.maxFeatures is int){
      _maxFeaturesWrapper.selectedIndex = 3;
      _maxFeaturesIntegerController.text = _model.maxFeatures.toString();
      _maxFeaturesFloatController.text = "50.00";
    }
    else if(_model.maxFeatures is double){
      _maxFeaturesWrapper.selectedIndex = 4;
      _maxFeaturesFloatController.text = (_model.maxFeatures*100.0).toStringAsFixed(2);
      _maxFeaturesIntegerController.text = "1";
    }
    else{
      _maxFeaturesWrapper.selectedIndex = _maxFeaturesWrapper.items.indexOf(_model.maxFeatures);
      _maxFeaturesFloatController.text = "50.00";
      _maxFeaturesIntegerController.text = "1";
    }
    if(_model.maxDepth != null){
      _maxDepthController.text = _model.maxDepth.toString();
      _maxDepthNullWrapper.value = false;
    }
    else{
      _maxDepthController.text = "1";
      _maxDepthNullWrapper.value = true;
    }
    _criterionWrapper.selectedIndex = _criterionWrapper.items.indexOf(_model.criterion);
    _splitterWrapper.selectedIndex = _splitterWrapper.items.indexOf(_model.splitter);
  }
}
