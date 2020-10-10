import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/random_forest_classifier_model.dart';
import 'package:prototyoe_project_app/models/random_forest_regressor_model.dart';
import 'package:prototyoe_project_app/widgets/inputs/Switch_Field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/max_features_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class RandomForestRegressorParameters extends ParameterStatefulWidget {

  RandomForestRegressorParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _RandomForestRegressorParametersState createState() => _RandomForestRegressorParametersState();
}

class _RandomForestRegressorParametersState extends ParameterState<RandomForestRegressorParameters> {

  static const List<String> _maxFeaturesChoices = const <String>['auto', 'sqrt', 'log2', 'Number', 'Percentage'];
  static const List<String> _criterionChoices = const <String>['mse', 'mae'];

  TextEditingController _maxDepthController = TextEditingController();
  TextEditingController _nEstimatorsController = TextEditingController();
  TextEditingController _maxFeaturesIntegerController = TextEditingController();
  TextEditingController _maxFeaturesFloatController = TextEditingController();

  BooleanWrapper _maxDepthNullWrapper = BooleanWrapper(initialValue: true);
  TextEditingController _ccpAlphaController = TextEditingController();

  DropDownSelectionWrapper _maxFeaturesWrapper = DropDownSelectionWrapper(
      items: _maxFeaturesChoices
  );
  DropDownSelectionWrapper _criterionWrapper = DropDownSelectionWrapper(
      items: _criterionChoices
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
                shortdesc: "The maximum depth of the tree.",
                desc: "\nThe maximum depth of the tree. If None, then nodes are expanded until all leaves are pure or until all leaves contain less than min_samples_split samples.",
                setValue: (int newValue) {
              setState(() {
                // _max_depthState = newValue;
                (widget.stateModel as RandomForestRegressorModel).maxDepth = newValue;
                if(widget.onChanged != null)
                  widget.onChanged();
              });}),

            NumField(
                controller: _nEstimatorsController,
                desc: "The number of trees in the forest.",
                name:'Number of Estimators',type: NumField.INTEGER, setValue: (int newValue) {
              setState(() {
                (widget.stateModel as RandomForestRegressorModel).nEstimators = newValue;
                if(widget.onChanged != null)
                  widget.onChanged();
              });}
            ),
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
                    (widget.stateModel as RandomForestRegressorModel).maxFeatures = newValue;
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
                    desc: "\nThe function to measure the quality of a split. Supported criteria are: "
                        "\n\n• “mse” for the mean squared error, which is equal to variance reduction as feature selection criterion."
                        "\n\n• “mae” for the mean absolute error.",
                    setValue: (String newValue) {
                      setState(() {
                        (widget.stateModel as RandomForestRegressorModel).criterion = newValue;
                        if(widget.onChanged != null)
                          widget.onChanged();
                      });}),

                NumField(
                    controller: _ccpAlphaController,
                    name:'Cost-Complexity Pruning Alpha',type: 1 ,
                    shortdesc: "Complexity parameter used for Minimal Cost-Complexity Pruning",
                    desc: "\nComplexity parameter used for Minimal Cost-Complexity Pruning. The subtree with the largest cost complexity that is smaller than ccp_alpha will be chosen. By default, no pruning is performed.",
                    setValue: (double newValue) {
                  setState(() {
                    (widget.stateModel as RandomForestRegressorModel).ccpAlpha = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),


                SwitchField(name:'Bootstrap',
                    shortdesc: "Whether bootstrap samples are used when building trees.",
                    desc: "\nWhether bootstrap samples are used when building trees. If False, the whole dataset is used to build each tree.",
                    booleanWrapper:_bootstrapWrapper, onChanged: (bool newValue) {
                      (widget.stateModel as RandomForestRegressorModel).bootstrap = _bootstrapWrapper.value;
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
    RandomForestRegressorModel _model = (widget.stateModel as RandomForestRegressorModel);

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
