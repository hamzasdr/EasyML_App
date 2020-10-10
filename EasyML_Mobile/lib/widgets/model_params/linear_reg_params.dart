import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/linear_reg_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/inputs/Switch_Field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class LinearRegressionParameters extends ParameterStatefulWidget {

  LinearRegressionParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _LinearRegressionParametersState createState() => _LinearRegressionParametersState();
}

class _LinearRegressionParametersState extends ParameterState<LinearRegressionParameters> {

  BooleanWrapper _fitInterceptState = BooleanWrapper(initialValue: false);
  BooleanWrapper _normalizeState = BooleanWrapper(initialValue: false);

  @override
  void initState() {
    super.initState();
    update();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
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
        SwitchField(name:'Fit Intercept',booleanWrapper:_fitInterceptState,
          shortdesc: "Whether to calculate the intercept for this model. ",
          desc: "Whether to calculate the intercept for this model. If set to False, no intercept will be used in calculations (i.e. data is expected to be centered).",
          onChanged: (_) => setState((){
          (widget.stateModel as LinearRegressionModel).fitIntercept = _fitInterceptState.value;
          if(widget.onChanged != null)
            widget.onChanged();
        }),),
        SwitchField(name:'Normalize',booleanWrapper:_normalizeState,
          shortdesc: "If True, the regressors X will be normalized before regression by subtracting the mean and dividing by the l2-norm.",
          desc: "This parameter is ignored when fit_intercept is set to False. If True, the regressors X will be normalized before regression by subtracting the mean and dividing by the l2-norm.",
          onChanged: (_) => setState((){
          (widget.stateModel as LinearRegressionModel).normalize = _normalizeState.value;
          if(widget.onChanged != null)
            widget.onChanged();
        }),),
//                  HelpTextField(name: "N_Jobs", controller: _n_jobs_controller),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  void update() {
    _fitInterceptState.value = (widget.stateModel as LinearRegressionModel).fitIntercept;
    _normalizeState.value = (widget.stateModel as LinearRegressionModel).normalize;
  }
}
