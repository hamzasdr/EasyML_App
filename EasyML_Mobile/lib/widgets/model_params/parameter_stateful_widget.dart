import 'package:flutter/cupertino.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/decision_tree_regressor_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/widgets/model_params/decision_tree_cls_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/kmeans_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/knn_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/linear_reg_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/mpl_cls_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/randomforest_cls_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/randomforest_reg_params.dart';
import 'package:prototyoe_project_app/widgets/model_params/unimplemented_params.dart';

import 'decision_tree_reg_params.dart';

abstract class ParameterStatefulWidget extends StatefulWidget {
  Model stateModel;
  Function onChanged;
  ParameterStatefulWidget({this.stateModel, this.onChanged, Key key}): super(key: key);

  factory ParameterStatefulWidget.fromModel({
    @required Model stateModel,
    @required Function onChanged,
    Key key
  }){
    switch(stateModel.type.programmaticName){
      case 'linearreg':
        return LinearRegressionParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'decisiontree_cls':
        return DecisionTreeClassifierParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'decisiontree_reg':
        return DecisionTreeRegressorParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'knn_cls':
        return KNearestNeighborsClassifierParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'knn_reg':
        return KNearestNeighborsRegressorParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'randomforest_cls':
        return RandomForestClassifierParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'randomforest_reg':
        return RandomForestRegressorParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'mpl_cls':
      case 'mpl_reg':
        return MultilayerPerceptronParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      case 'kmeans':
        return KMeansParameters(stateModel: stateModel, onChanged: onChanged, key: key);
      default:
        return UnimplementedParameters(stateModel: stateModel, onChanged: onChanged, key: key);

    }
  }
}

abstract class ParameterState<T extends ParameterStatefulWidget> extends State<T>{
  void update();
}