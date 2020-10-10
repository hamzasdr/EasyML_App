import 'model.dart';
import 'model_type.dart';

class RandomForestClassifierModel extends Model{
    String classWeight;
    int nEstimators;
    String criterion;
    int maxDepth;
    dynamic maxFeatures;
    bool bootstrap;
    int verbose;
    double ccpAlpha;

    RandomForestClassifierModel({
      this.nEstimators = 100,
      this.criterion = 'gini',
      this.maxDepth,
      this.maxFeatures = 'auto',
      this.bootstrap = true,
      this.classWeight = 'balanced',
      this.ccpAlpha = 0.0,
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
        'n_estimators': nEstimators,
        'criterion': criterion,
        'max_depth': maxDepth,
        'max_features': maxFeatures,
        'bootstrap': bootstrap,
        'ccp_alpha': ccpAlpha,
        'class_weight': classWeight
      });
      return json;
    }



    @override
    bool equals(Model model){
      if(!(model is RandomForestClassifierModel))
        return false;
      RandomForestClassifierModel _model = model as RandomForestClassifierModel;
      return super.equals(_model) &&
          nEstimators == _model.nEstimators &&
          criterion == _model.criterion &&
          maxDepth == _model.maxDepth &&
          maxFeatures == _model.maxFeatures &&
          bootstrap == _model.bootstrap &&
          classWeight == _model.classWeight &&
          ccpAlpha == _model.ccpAlpha ;
    }

    static const List<String> libraries = const [
      'from sklearn.ensemble import RandomForestClassifier\n',
    ];
    static const List<String> creation = const [
      'model = RandomForestClassifier(n_estimators=n_estimators,\n',
      '                               max_depth=max_depth,\n',
      '                               max_features=max_features,\n',
      '                               criterion=criterion\n',
      '                               bootstrap=bootstrap\n',
      '                               class_weight=class_weight\n',
      '                               ccp_alpha=ccp_alpha\n',
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
        'n_estimators = $nEstimators\n',
        'max_depth = $_maxDepth\n',
        'max_features = $_maxFeatures\n',
        'criterion = "$criterion"\n',
        'bootstrap = ${bootstrap ? 'True' : 'False'}\n',
        'class_weight = "$classWeight"\n',
        'ccp_alpha = $ccpAlpha\n',
      ];
      return generateCodeBlocks(libraries, parameters, creation);
    }
}

