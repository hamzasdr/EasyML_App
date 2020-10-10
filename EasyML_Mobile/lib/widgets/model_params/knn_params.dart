import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/K_nearest_neighbor_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';



class KNearestNeighborsClassifierParameters extends ParameterStatefulWidget {

  KNearestNeighborsClassifierParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _KNearestNeighborsClassifierParametersState createState() => _KNearestNeighborsClassifierParametersState();

}

class _KNearestNeighborsClassifierParametersState extends ParameterState<KNearestNeighborsClassifierParameters> with TickerProviderStateMixin {

  static const List<String> _algorithms = const <String>['auto', 'ball_tree','kd_tree', 'brute'];
  static const List<String> _weights = const <String>['uniform', 'distance'];
  bool _initialized = false;
  TextEditingController _nNeighborsController = TextEditingController();
  DropDownSelectionWrapper _algorithmsWrapper = DropDownSelectionWrapper(
    items: _algorithms,
    enableDefaultValue: false
  );
  DropDownSelectionWrapper _weightsWrapper = DropDownSelectionWrapper(
    items: _weights,
    enableDefaultValue: false
  );

  @override
  void initState() {
    super.initState();
    update();
  }


  @override
  Widget build(BuildContext context) {
    print('rebuilt knn');
    if(widget.stateModel == null)
      return SizedBox();

    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
//            CreateModelPage(modelType: widget.modelType),

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
                  name:'Number of neighbors',
                  value:(widget.stateModel as KNearestNeighborsClassifierModel).nNeighbors,
                  type: 0 ,
                  controller: _nNeighborsController,
                  desc: "Number of neighbors to use by default for k-neighbors queries.",
                  setValue: (int newValue) {
                setState(() {
                  (widget.stateModel as KNearestNeighborsClassifierModel).nNeighbors = newValue;
                  if(widget.onChanged != null)
                    widget.onChanged();
                });}),
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
                      wrapper: _algorithmsWrapper,
                      name:'Algorithm',
                      shortdesc: "Algorithm used to compute the nearest neighbors:",
                      desc: "\n Algorithm used to compute the nearest neighbors: \n\n"
                          "• ‘ball_tree’ : will use BallTree \n\n"
                          "• ‘kd_tree’ : will use KDTree \n\n"
                          "• ‘brute’ : will use a brute-force search.\n\n"
                          "• ‘auto’ : will attempt to decide the most appropriate algorithm based on the values passed to fit method.",
                      setValue: (String newValue) {
                    setState(() {
//                          print(newValue);
                      (widget.stateModel as KNearestNeighborsClassifierModel).algorithm = newValue;
                      if(widget.onChanged != null)
                        widget.onChanged();
                    });}),
                  DynamicField(
                      wrapper: _weightsWrapper,
                      name:'Weights',
                      shortdesc:"weight function used in prediction. Possible values:",
                      desc: "\nWeight function used in prediction. \n\n"
                          "• ‘uniform’ : uniform weights. All points in each neighborhood are weighted equally.\n\n"
                          "• ‘distance’ : weight points by the inverse of their distance. In this case, closer neighbors of a query point will have a greater influence than neighbors which are further away.",
                      setValue: (String newValue) {
                    setState(() {
//                          print(newValue);
                      (widget.stateModel as KNearestNeighborsClassifierModel).weights = newValue;
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
    _nNeighborsController.text = (widget.stateModel as KNearestNeighborsClassifierModel).nNeighbors.toString();
    _algorithmsWrapper.selectedIndex = _algorithmsWrapper.items.indexOf((widget.stateModel as KNearestNeighborsClassifierModel).algorithm);
    _weightsWrapper.selectedIndex = _weightsWrapper.items.indexOf((widget.stateModel as KNearestNeighborsClassifierModel).weights);
  }

}

class KNearestNeighborsRegressorParameters extends ParameterStatefulWidget {

  KNearestNeighborsRegressorParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _KNearestNeighborsRegressorParametersState createState() => _KNearestNeighborsRegressorParametersState();

}

class _KNearestNeighborsRegressorParametersState extends ParameterState<KNearestNeighborsRegressorParameters> with TickerProviderStateMixin {

  static const List<String> _algorithms = const <String>['auto', 'ball_tree','kd_tree', 'brute'];
  static const List<String> _weights = const <String>['uniform', 'distance'];
  bool _initialized = false;
  TextEditingController _nNeighborsController = TextEditingController();
  DropDownSelectionWrapper _algorithmsWrapper = DropDownSelectionWrapper(
      items: _algorithms,
      enableDefaultValue: false
  );
  DropDownSelectionWrapper _weightsWrapper = DropDownSelectionWrapper(
      items: _weights,
      enableDefaultValue: false
  );

  @override
  void initState() {
    super.initState();
    update();
  }


  @override
  Widget build(BuildContext context) {
    print('rebuilt knn');
    if(widget.stateModel == null)
      return SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
//            CreateModelPage(modelType: widget.modelType),

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
                name:'n_neighbors',
                value:(widget.stateModel as KNearestNeighborsRegressorModel).nNeighbors,
                type: 0 ,
                controller: _nNeighborsController,
                desc: "Number of neighbors to use by default for k-neighbors queries.",
                setValue: (int newValue) {
                  setState(() {
                    (widget.stateModel as KNearestNeighborsRegressorModel).nNeighbors = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),
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
                    wrapper: _algorithmsWrapper,
                    name:'Algorithm',
                    shortdesc: "Algorithm used to compute the nearest neighbors:",
                    desc: "\n Algorithm used to compute the nearest neighbors: \n\n"
                        "• ‘ball_tree’ : will use BallTree \n\n"
                        "• ‘kd_tree’ : will use KDTree \n\n"
                        "• ‘brute’ : will use a brute-force search.\n\n"
                        "• ‘auto’ : will attempt to decide the most appropriate algorithm based on the values passed to fit method.",
                    setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        (widget.stateModel as KNearestNeighborsRegressorModel).algorithm = newValue;
                        if(widget.onChanged != null)
                          widget.onChanged();
                      });}),
                DynamicField(
                    wrapper: _weightsWrapper,
                    name:'weights',
                    shortdesc:"weight function used in prediction. Possible values:",
                    desc: "\nWeight function used in prediction. \n\n"
                        "• ‘uniform’ : uniform weights. All points in each neighborhood are weighted equally.\n\n"
                        "• ‘distance’ : weight points by the inverse of their distance. In this case, closer neighbors of a query point will have a greater influence than neighbors which are further away.",
                    setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        (widget.stateModel as KNearestNeighborsRegressorModel).weights = newValue;
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
    _nNeighborsController.text = (widget.stateModel as KNearestNeighborsRegressorModel).nNeighbors.toString();
    _algorithmsWrapper.selectedIndex = _algorithmsWrapper.items.indexOf((widget.stateModel as KNearestNeighborsRegressorModel).algorithm);
    _weightsWrapper.selectedIndex = _weightsWrapper.items.indexOf((widget.stateModel as KNearestNeighborsRegressorModel).weights);
  }

}