import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/K_nearest_neighbor_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';



class UnimplementedParameters extends ParameterStatefulWidget {

  UnimplementedParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  _unimplementedParametersState createState() => _unimplementedParametersState();

}

class _unimplementedParametersState extends ParameterState<UnimplementedParameters> with TickerProviderStateMixin {


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
        Center(
          child: Text("Unimplemented"),
        )
      ],
    );
  }

  @override
  void update() {
  }

}