import 'package:prototyoe_project_app/models/model.dart';

import 'model_type.dart';

class KMeansModel extends Model{
  int nClusters;
  int maxIter;
  String algorithm;
  double tol;

  KMeansModel({
    this.nClusters = 8,
    this.maxIter = 300,
    this.tol = 0.0001,
    this.algorithm = 'elkan',
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
      'n_clusters': nClusters,
      'max_iter': maxIter,
      'tol': tol,
      'algorithm': algorithm,

    });
    return json;
  }


  @override
  bool equals(Model model){
    if(!(model is KMeansModel))
      return false;
    KMeansModel _model = model as KMeansModel;
    return super.equals(_model) &&
        nClusters == _model.nClusters &&
        maxIter == maxIter &&
        tol == _model.tol &&
        algorithm == _model.algorithm ;
  }

  static const List<String> libraries = const [
    'from sklearn.cluster import KMeans\n',
  ];
  static const List<String> creation = const [
    'model = KMeans(n_clusters=n_clusters,\n',
    '               max_iter=max_iter,\n',
    '               algorithm=algorithm\n',
    '               tol=tol)\n',
  ];

  @override
  List<List<String>> get codeBlocks{
    List<String> parameters = [
      'n_clusters = $nClusters\n',
      'max_iter = $maxIter\n',
      'tol = $tol\n',
      'algorithm = "$algorithm"\n',
    ];
    return generateCodeBlocks(libraries, parameters, creation);
  }
}