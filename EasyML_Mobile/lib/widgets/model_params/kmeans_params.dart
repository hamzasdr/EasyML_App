import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/kmeans.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';

class KMeansParameters extends ParameterStatefulWidget {

  KMeansParameters({Model stateModel, Function onChanged, Key key}): super(stateModel: stateModel, onChanged: onChanged, key: key);
  @override
  ParameterState createState() => _KMeansParametersState();

}

class _KMeansParametersState extends ParameterState<KMeansParameters> with TickerProviderStateMixin {

  static const List<String> _algorithms = const <String>['auto', 'full','elkan'];
  TextEditingController _nClustersController = TextEditingController();
  TextEditingController _maxIterController = TextEditingController();
  TextEditingController _tolController = TextEditingController();

  DropDownSelectionWrapper _algorithmsWrapper = DropDownSelectionWrapper(
      items: _algorithms,
      enableDefaultValue: false
  );

  @override
  void initState() {
    super.initState();
    update();
  }


  @override
  Widget build(BuildContext context) {
    if(widget.stateModel == null)
      return SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                name:'Number of clusters',
                value:(widget.stateModel as KMeansModel).nClusters,
                type: NumField.INTEGER ,
                controller: _nClustersController,
                desc: "The number of clusters to form as well as the number of centroids to generate.",
                setValue: (int newValue) {
                  setState(() {
                    (widget.stateModel as KMeansModel).nClusters = newValue;
                    if(widget.onChanged != null)
                      widget.onChanged();
                  });}),
            NumField(
                name:'Maximum Iterations',
                value:(widget.stateModel as KMeansModel).maxIter,
                type: NumField.INTEGER ,
                controller: _maxIterController,
                desc: "Maximum number of iterations of the k-means algorithm for a single run.",
                setValue: (int newValue) {
                  setState(() {
                    (widget.stateModel as KMeansModel).maxIter = newValue;
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
                    shortdesc: "",
                    desc: "K-means algorithm to use. The classical EM-style algorithm is “full”. The “elkan” variation is more efficient on data with well-defined clusters, by using the triangle inequality."
                        "However it’s more memory intensive due to the allocation of an extra array of shape (n_samples, n_clusters).",
                    setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        (widget.stateModel as KMeansModel).algorithm = newValue;
                        if(widget.onChanged != null)
                          widget.onChanged();
                      });}),
                NumField(
                    name:'Tolerance',
                    value:(widget.stateModel as KMeansModel).tol,
                    type: NumField.DOUBLE ,
                    controller: _tolController,
                    desc: "Relative tolerance with regards to Frobenius norm of the difference in the cluster centers of two consecutive iterations to declare convergence. "
                        "It’s not advised to set tolerance = 0 since convergence might never be declared due to rounding errors. Use a very small number instead.",
                    setValue: (double newValue) {
                      setState(() {
                        (widget.stateModel as KMeansModel).tol = newValue;
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
    _nClustersController.text = (widget.stateModel as KMeansModel).nClusters.toString();
    _maxIterController.text = (widget.stateModel as KMeansModel).maxIter.toString();
    _tolController.text = (widget.stateModel as KMeansModel).tol.toString();
    _algorithmsWrapper.selectedIndex = _algorithmsWrapper.items.indexOf((widget.stateModel as KMeansModel).algorithm);
  }

}