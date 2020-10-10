import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/carousels/layer_carousel.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_addmulti_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class MultilayerPerceptronParameters extends ParameterStatefulWidget {

  MultilayerPerceptronParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _MultilayerPerceptronParametersState createState() => _MultilayerPerceptronParametersState();
}

class _MultilayerPerceptronParametersState extends ParameterState<MultilayerPerceptronParameters> {

  static const List<String> _activationChoices = const <String>['identity', 'logistic', 'tanh', 'relu'];
  static const List<String> _learningRateChoices = const <String>['constant', 'invscaling', 'adaptive'];
  static const List<String> _solverChoices = const <String>['lbfgs', 'sgd', 'adam'];

  TextEditingController _maxIterationsController = TextEditingController();
  TextEditingController _initialLearningRateController = TextEditingController();
  TextEditingController _toleranceController = TextEditingController();

  TextEditingController _layerController = TextEditingController();

  DropDownSelectionWrapper _activationFunctionWrapper = DropDownSelectionWrapper(
    items: _activationChoices
  );
  DropDownSelectionWrapper _learningRateWrapper = DropDownSelectionWrapper(
    items: _learningRateChoices
  );
  DropDownSelectionWrapper _solverWrapper = DropDownSelectionWrapper(
    items: _solverChoices
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
              controller: _maxIterationsController,
                name:'Max Iterations',type: 0 ,
                shortdesc: "Maximum number of iterations.",
                desc: "Maximum number of iterations. The solver iterates until convergence (determined by ‘Tolerance’) or this number of iterations. For stochastic solvers (‘sgd’, ‘adam’), note that this determines the number of epochs (how many times each data point will be used), not the number of gradient steps.",
                setValue: (int newValue) {
              setState(() {
                (widget.stateModel as MultilayerPerceptronModel).maxIter = newValue;
                if(widget.onChanged != null)
                  widget.onChanged();
              });}),

            AddMultiFields(
              name: "Add Hidden Layer",controller:_layerController,
              desc: "Add a Hidden Layer with N neurons",
              onAdd: (int value){
              setState(() {
                (widget.stateModel as MultilayerPerceptronModel).hiddenLayerSizes.add(value);
              });
              if(widget.onChanged != null)
                widget.onChanged();
            },),
            LayersCarousel(model: widget.stateModel, onChanged: (){
              setState((){});
              if(widget.onChanged != null)
                widget.onChanged();
            },),
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
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,),
                textAlign: TextAlign.justify,),
            ],
          ),
          subtitle: Icon(Icons.keyboard_arrow_down),
          children: <Widget>[
            Column(
              children: <Widget>[
                DynamicField(
                  wrapper: _activationFunctionWrapper,
                    name:'Activation',
                    shortdesc: "Activation function for the hidden layer.",
                    desc: "\n Activation function for the hidden layer.\n\n • identity : no-op activation, useful to implement linear bottleneck, returns f(x) = x \n\n • logistic : the logistic sigmoid function, returns f(x) = 1 / (1 + exp(-x)). \n\n • tanh : the hyperbolic tan function, returns f(x) = tanh(x). \n\n  • relu : the rectified linear unit function, returns f(x) = max(0, x)",
                    setValue: (String newValue) {
                  setState(() {
                    (widget.stateModel as MultilayerPerceptronModel).activation = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                DynamicField(
                  wrapper: _solverWrapper,
                    name:'Solvers',
                    shortdesc: "The solver for weight optimization.",
                    desc: "\n The solver for weight optimization. \n\n • lbfgs : is an optimizer in the family of quasi-Newton methods. \n\n • sgd : refers to stochastic gradient descent. \n\n • adam : refers to a stochastic gradient-based optimizer proposed by Kingma, Diederik, and Jimmy Ba",
                    setValue: (String newValue) {
                  setState(() {
                    (widget.stateModel as MultilayerPerceptronModel).solver = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                DynamicField(
                  wrapper: _learningRateWrapper,
                    name:'Learning Rate',
                    shortdesc: "Learning rate schedule for weight updates",
                    desc: " \n Learning rate schedule for weight updates \n\n • constant : is a constant learning rate given by ‘Initial learning rate’. \n\n • invscaling : gradually decreases the learning rate at each time step ‘t’ using an inverse scaling exponent of ‘0.5’. Effective learning rate = (Initial learning rate) / (t^ 0.5) \n\n • adaptive : keeps the learning rate constant to the inital learning rate as long as training loss keeps decreasing. Each time two consecutive epochs fail to decrease training loss by at least (Tolerance), the current learning rate is divided by 5. \n ",
                    setValue: (String newValue) {
                  setState(() {
                    (widget.stateModel as MultilayerPerceptronModel).learningRate = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                NumField(
                  controller: _initialLearningRateController,
                    name:'Intial Learning Rate',type: 1 ,
                    shortdesc: "The initial learning rate used.",
                    desc: "The initial learning rate used. It controls the step-size in updating the weights. Only used when solver=’sgd’ or ‘adam’.",
                    setValue: (double newValue) {
                  setState(() {
                    (widget.stateModel as MultilayerPerceptronModel).learningRateInit = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),

                NumField(
                  controller: _toleranceController,
                    name:'Tolerance',type: 1 ,
                    shortdesc: "Tolerance for the optimization.",
                    desc: "Tolerance for the optimization. When the loss or score is not improving by at least this tolerance for 10 consecutive iterations, unless the learning rate is set to ‘adaptive’, convergence is considered to be reached and training stops.",
                    setValue: (double newValue) {
                  setState(() {
                    (widget.stateModel as MultilayerPerceptronModel).tol = newValue;
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
        SizedBox(height: 50,),
      ],
    );
  }

  @override
  void update() {
    MultilayerPerceptronModel _model = (widget.stateModel as MultilayerPerceptronModel);
    _maxIterationsController.text = _model.maxIter.toString();
    _initialLearningRateController.text = _model.learningRateInit.toString();
    _toleranceController.text = _model.tol.toString();

    _activationFunctionWrapper.selectedIndex = _activationFunctionWrapper.items.indexOf(_model.activation);
    _learningRateWrapper.selectedIndex = _learningRateWrapper.items.indexOf(_model.learningRate);
    _solverWrapper.selectedIndex = _solverWrapper.items.indexOf(_model.solver);
  }
}
