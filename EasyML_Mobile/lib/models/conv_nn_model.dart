
import 'dart:convert';

import 'layer_type.dart';
import 'model.dart';
import 'model_type.dart';

class MultilayerPerceptronModel extends Model{

  int maxIter;
  List<int> hiddenLayerSizes;
  String activation;
  String solver;
  String learningRate;
  double learningRateInit;
  double tol;


  MultilayerPerceptronModel({
    this.maxIter = 200,
    this.activation = 'relu',
    this.solver = 'adam',
    this.learningRate = 'constant',
    this.learningRateInit = 0.001,
    this.tol = 0.0001,
    int id,
    String name,
    ModelType type,
    bool beingTrained=false,
    bool synced=false,
    Map<String, dynamic> info,
    List<int> hiddenLayerSizes,
    }):super(
      id: id,
      name: name,
      type: type,
      beingTrained: beingTrained,
      synced: synced,
      info: info
  )
  {
    if(hiddenLayerSizes != null && hiddenLayerSizes.length > 0)
      this.hiddenLayerSizes = hiddenLayerSizes.map((e) => e).toList(); // copy
    else
      this.hiddenLayerSizes = <int>[100,];
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'hidden_layer_sizes': jsonEncode(hiddenLayerSizes),
      'max_iter': maxIter,
      'activation': activation,
      'solver': solver,
      'learning_rate': learningRate,
      'learning_rate_init': learningRateInit,
      'tol': tol,
    });
    return json;
  }

  @override
  bool equals(Model model){
    if(!(model is MultilayerPerceptronModel))
      return false;
    MultilayerPerceptronModel _model = model as MultilayerPerceptronModel;
    if(hiddenLayerSizes.length != _model.hiddenLayerSizes.length)
      return false;
//
//    bool listsEqual = true;
//    for(int i = 0; i < hidden_layers.length; i++)
//        if(hidden_layers[i] != _model.hidden_layers[i]){
//          listsEqual = false;
//          break;
//        }

        return super.equals(_model) &&
          hiddenLayerSizes.asMap().entries.where((element) => element.value != _model.hiddenLayerSizes[element.key]).length == 0 &&
          maxIter == _model.maxIter &&
          activation == _model.activation &&
          solver == _model.solver &&
          learningRate == _model.learningRate &&
          learningRateInit == _model.learningRateInit &&
          tol == _model.tol ;
  }

  List<String> get libraries => [
    'sklearn.neural_network import MLP${type.category==ModelCategory.REGRESSION?'Regressor':'Classifier'}\n',
  ];
  List<String> get creation => [
    'mpl = MLP${type.category==ModelCategory.REGRESSION?'Regressor':'Classifier'}(hidden_layer_sizes=hidden_layer_sizes,\n',
    '${type.category==ModelCategory.REGRESSION?'':' '}                   max_iter=max_iter,\n',
    '${type.category==ModelCategory.REGRESSION?'':' '}                   activation=activation,\n',
    '${type.category==ModelCategory.REGRESSION?'':' '}                   solver=solver,\n',
    '${type.category==ModelCategory.REGRESSION?'':' '}                   learning_rate=learning_rate,\n',
    '${type.category==ModelCategory.REGRESSION?'':' '}                   learning_rate_init=learning_rate_init,\n',
    '${type.category==ModelCategory.REGRESSION?'':' '}                   tol=tol\n)',
  ];

  @override
  List<List<String>> get codeBlocks{
    String _hiddenLayerSizes = '(';
    if(hiddenLayerSizes.length == 0)
      _hiddenLayerSizes += '100,';
    else{
      hiddenLayerSizes.forEach((int hiddenLayer)=>_hiddenLayerSizes+="$hiddenLayer, ");
      _hiddenLayerSizes = _hiddenLayerSizes.substring(0, _hiddenLayerSizes.length-1);
    }
    _hiddenLayerSizes += ')';
    List<String> parameters = [
      'hidden_layer_sizes = $_hiddenLayerSizes\n',
      'max_iter = $maxIter\n',
      'activation = \"$activation\"\n',
      'solver = \"$solver\"\n',
      'learning_rate = \"$learningRate\"\n',
      'learning_rate_init = $learningRateInit\n',
      'tol = $tol\n',
    ];
    return generateCodeBlocks(libraries, parameters, creation);
  }

}
