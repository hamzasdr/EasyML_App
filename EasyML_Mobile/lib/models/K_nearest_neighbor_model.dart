import 'model.dart';
import 'model_type.dart';

class KNearestNeighborsClassifierModel extends Model{

  int nNeighbors;
  dynamic weights;
  String algorithm;

  KNearestNeighborsClassifierModel({
    this.nNeighbors = 5,
    this.weights = 'uniform',
    this.algorithm = 'auto',


    int id,
    String name,
    ModelType type,
    bool beingTrained = false,
    bool synced = false,
    Map<String, dynamic> info,
  }):super(
    id: id,
    name: name,
    type: type,
    beingTrained: beingTrained,
    synced: synced,
    info: info
  );

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'n_neighbors': nNeighbors,
      'weights': weights,
      'algorithm': algorithm,

    });
    return json;
  }


  @override
  bool equals(Model model){
    if(!(model is KNearestNeighborsClassifierModel))
      return false;
    KNearestNeighborsClassifierModel _model = model as KNearestNeighborsClassifierModel;
    return super.equals(_model) &&
        nNeighbors == _model.nNeighbors &&
        weights == _model.weights &&
        algorithm == _model.algorithm ;
//        leaf_size == _model.leaf_size &&
//        p == _model.p &&
//        metric == _model.metric &&
//        metric_paramsdict == _model.metric_paramsdict;
  }

  static const List<String> libraries = const [
    'from sklearn.neighbors import KNeighborsClassifier\n',
  ];
  static const List<String> creation = const [
    'model = KNeighborsClassifier(n_neighbors=n_neighbors,\n',
    '                             weights=weights,\n',
    '                             algorithm=algorithm\n',
  ];

  @override
  List<List<String>> get codeBlocks{
    List<String> parameters = [
      'n_neighbors = $nNeighbors\n',
      'weights = "$weights"\n',
      'algorithm = "$algorithm"\n',
    ];
    return generateCodeBlocks(libraries, parameters, creation);
  }
}

class KNearestNeighborsRegressorModel extends Model{

  int nNeighbors;
  dynamic weights;
  String algorithm;

  KNearestNeighborsRegressorModel({
    this.nNeighbors = 5,
    this.weights = 'uniform',
    this.algorithm = 'auto',


    int id,
    String name,
    ModelType type,
    bool beingTrained = false,
    bool synced = false,
    Map<String, dynamic> info,
  }):super(
      id: id,
      name: name,
      type: type,
      beingTrained: beingTrained,
      synced: synced,
      info: info
  );

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'n_neighbors': nNeighbors,
      'weights': weights,
      'algorithm': algorithm,

    });
    return json;
  }


  @override
  bool equals(Model model){
    if(!(model is KNearestNeighborsRegressorModel))
      return false;
    KNearestNeighborsRegressorModel _model = model as KNearestNeighborsRegressorModel;
    return super.equals(_model) &&
        nNeighbors == _model.nNeighbors &&
        weights == _model.weights &&
        algorithm == _model.algorithm ;
  }

  static const List<String> libraries = const [
    'from sklearn.neighbors import KNeighborsRegressor\n',
  ];
  static const List<String> creation = const [
    'model = KNeighborsRegressor(n_neighbors=n_neighbors,\n',
    '                            weights=weights,\n',
    '                            algorithm=algorithm\n',
  ];

  @override
  List<List<String>> get codeBlocks{
    List<String> parameters = [
      'n_neighbors = $nNeighbors\n',
      'weights = "$weights"\n',
      'algorithm = "$algorithm"\n',
    ];
    return generateCodeBlocks(libraries, parameters, creation);
  }
}