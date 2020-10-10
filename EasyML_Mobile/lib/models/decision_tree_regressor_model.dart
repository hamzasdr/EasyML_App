import 'model.dart';
import 'model_type.dart';

class DecisionTreeRegressorModel extends Model{

  String criterion;
  String splitter;
  int maxDepth;
  dynamic maxFeatures;


  DecisionTreeRegressorModel({
    this.criterion = 'mse',
    this.splitter = 'best',
    this.maxDepth,
    this.maxFeatures = 'auto',
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
    info: info,
  );

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'criterion': criterion,
      'splitter': splitter,
      'max_depth': maxDepth,
      'max_features': maxFeatures,
    });
    return json;
  }


  @override
  bool equals(Model model){
    if(!(model is DecisionTreeRegressorModel))
      return false;
    DecisionTreeRegressorModel _model = model as DecisionTreeRegressorModel;
    return super.equals(_model) &&
        criterion == _model.criterion &&
        maxDepth == _model.maxDepth &&
        maxFeatures == _model.maxFeatures ;
  }

  static const List<String> libraries = const [
    'from sklearn.tree import DecisionTreeRegressor\n',
  ];
  static const List<String> creation = const [
    'model = DecisionTreeRegressor(criterion=criterion,\n',
    '                              splitter=splitter,\n',
    '                              max_depth=max_depth,\n',
    '                              max_features=max_features\n',
  ];

  @override
  List<List<String>> get codeBlocks{
    String _maxFeatures;
    if(maxFeatures == null)
      _maxFeatures = "None";
    else if(maxFeatures is int || maxFeatures is double)
      _maxFeatures = "$maxFeatures";
    else
      _maxFeatures = "\"$maxFeatures\"";
    String _maxDepth;
    if(maxDepth == null)
      _maxDepth = "None";
    else
      _maxDepth = "$maxDepth";
    List<String> parameters = [
      'criterion = "$criterion"\n',
      'splitter = "$splitter"\n',
      'max_depth = $_maxDepth\n',
      'max_features = $_maxFeatures\n',
    ];
    return generateCodeBlocks(libraries, parameters, creation);
  }
}

