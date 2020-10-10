import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/random_forest_classifier_model.dart';
import 'package:prototyoe_project_app/widgets/inputs/Switch_Field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_dropdown.dart';
import 'package:prototyoe_project_app/widgets/inputs/max_features_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class RandomForestClassifierParameters extends ParameterStatefulWidget {

  RandomForestClassifierParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _RandomForestClassifierParametersState createState() => _RandomForestClassifierParametersState();
}

class _RandomForestClassifierParametersState extends ParameterState<RandomForestClassifierParameters> {

  static const List<String> _maxFeaturesChoices = const <String>['auto', 'sqrt', 'log2', 'Number', 'Percentage'];
  static const List<String> _criterionChoices = const <String>['gini', 'entropy'];
  static const List<String> _classWeightChoices = const <String>['balanced', 'balanced_subsample'];

  TextEditingController _maxDepthController = TextEditingController();
  BooleanWrapper _maxDepthNullWrapper = BooleanWrapper(initialValue: true);
  TextEditingController _nEstimatorsController = TextEditingController();
  TextEditingController _maxFeaturesIntegerController = TextEditingController();
  TextEditingController _maxFeaturesFloatController = TextEditingController();
  TextEditingController _ccpAlphaController = TextEditingController();

  DropDownSelectionWrapper _maxFeaturesWrapper = DropDownSelectionWrapper(
    items: _maxFeaturesChoices
  );
  DropDownSelectionWrapper _criterionWrapper = DropDownSelectionWrapper(
    items: _criterionChoices
  );
  DropDownSelectionWrapper _classWeightWrapper = DropDownSelectionWrapper(
    items: _classWeightChoices
  );
  BooleanWrapper _bootstrapWrapper = BooleanWrapper(initialValue: false);

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[SizedBox(height: 20),
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
                desc: "The maximum depth of the tree. If None, then nodes are expanded until all leaves are pure or until all leaves contain less than min_samples_split samples.\n",
                setValue: (int newValue) {
              setState(() {
                // _max_depthState = newValue;
                (widget.stateModel as RandomForestClassifierModel).maxDepth = newValue;
                if(widget.onChanged != null)
                  widget.onChanged();
              });}),

            NumField(
              controller: _nEstimatorsController,
                name:'Number of Estimators',type: 0 ,
                desc: "The number of trees in the forest.\n",
                setValue: (int newValue) {
              setState(() {
                (widget.stateModel as RandomForestClassifierModel).nEstimators = newValue;
                if(widget.onChanged != null)
                  widget.onChanged();
              });}
              ),

            MaxFeaturesField(
//              oldStyle: true,
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
                  (widget.stateModel as RandomForestClassifierModel).maxFeatures = newValue;
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
                    (widget.stateModel as RandomForestClassifierModel).criterion = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                DynamicField(
                    wrapper: _classWeightWrapper,
                    name:'Class Weights',
                    shortdesc: "Weights associated with classes in the form {class_label: weight}.",
                    desc: "\nWeights associated with classes in the form {class_label: weight}. If not given, all classes are supposed to have weight one. For multi-output problems, a list of dicts can be provided in the same order as the columns of y.",
                    setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        (widget.stateModel as RandomForestClassifierModel).classWeight = newValue;
                        if(widget.onChanged != null)
                          widget.onChanged();
                      });}),

                NumField(
                    controller: _ccpAlphaController,
                    name:'Cost-Complexity Pruning Alpha',type: NumField.DOUBLE,
                    shortdesc: "Complexity parameter used for Minimal Cost-Complexity Pruning",
                    desc: "\nComplexity parameter used for Minimal Cost-Complexity Pruning. The subtree with the largest cost complexity that is smaller than ccp_alpha will be chosen. By default, no pruning is performed.",
                    setValue: (double newValue) {
                      setState(() {
                        (widget.stateModel as RandomForestClassifierModel).ccpAlpha = newValue;
                        if(widget.onChanged != null)
                          widget.onChanged();
                      });}),


                SwitchField(name:'Bootstrap',
                    shortdesc: "Whether bootstrap samples are used when building trees.",
                    desc: "\nWhether bootstrap samples are used when building trees. If False, the whole dataset is used to build each tree.\n\n\n",
                    booleanWrapper:_bootstrapWrapper, onChanged: (bool newValue) {
                  (widget.stateModel as RandomForestClassifierModel).bootstrap = _bootstrapWrapper.value;
                  if(widget.onChanged != null)
                    widget.onChanged();
                }
                ),
//                      SwitchField(name:'oob_score',booleanWrapper:_oob_scoreState, onChanged: (bool newValue) {
//                        setState(() {});
//                      }
//                      ),

//                      SwitchField(name:'warm start',booleanWrapper:_warm_startState, onChanged: (bool newValue) {
//                        setState(() {
//                        });
//                      }
//                      ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 5,),],
    );
  }

  @override
  void update() {
    RandomForestClassifierModel _model = (widget.stateModel as RandomForestClassifierModel);

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

    _maxDepthController.text = _model.maxDepth.toString();
    _criterionWrapper.selectedIndex = _criterionWrapper.items.indexOf(_model.criterion);
    _classWeightWrapper.selectedIndex = _classWeightWrapper.items.indexOf(_model.classWeight);

    _bootstrapWrapper.value = _model.bootstrap;

    if(_model.maxDepth != null){
      _maxDepthController.text = _model.maxDepth.toString();
      _maxDepthNullWrapper.value = false;
    }
    else{
      _maxDepthController.text = "1";
      _maxDepthNullWrapper.value = true;
    }
    _nEstimatorsController.text = _model.nEstimators.toString();
    _ccpAlphaController.text = _model.ccpAlpha.toString();
  }
}
