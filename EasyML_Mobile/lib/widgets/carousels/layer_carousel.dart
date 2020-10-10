import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/layer_type.dart';
import 'package:prototyoe_project_app/pages/SeeAll_page.dart';
import 'package:prototyoe_project_app/archive/create_layer_dialog.dart';
import 'package:prototyoe_project_app/widgets/layer_item.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:provider/provider.dart';

//List<String> Activations = <String>['ReLU', 'Tanh', 'Sigmoid', 'Linear'];
//String Activation = 'ReLU';

//int ID = 1;

class LayersCarousel extends StatefulWidget {
  MultilayerPerceptronModel model;
  Function onChanged;
  LayersCarousel({this.model, this.onChanged});
  @override
  _LayersCarouselState createState() => _LayersCarouselState();
}

class _LayersCarouselState extends State<LayersCarousel> {

  @override
  Widget build(BuildContext context) {
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
//          color: Colors.red,
          height: 110,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: ReorderableListView(

              onReorder: (int oldIndex, int newIndex){
                if(oldIndex == newIndex) {}
                else{
//                  Layer layer = widget.model.layers[oldIndex];
                  int nodes = widget.model.hiddenLayerSizes[oldIndex];
                  widget.model.hiddenLayerSizes.removeAt(oldIndex);
                  if(oldIndex < newIndex)
                    newIndex--;
                  widget.model.hiddenLayerSizes.insert(newIndex, nodes);
                  if(widget.onChanged != null)
                    widget.onChanged();
                }
              },
              scrollDirection: Axis.horizontal,
                  children: widget.model.hiddenLayerSizes.asMap().entries.map((entry) {
                      int index = entry.key;
                    return Container(
                        key: Key("layer" + index.toString()),
                        child: Stack(children: <Widget>[
                          LayerItem(model: widget.model,index:index, onChanged: (){
                            setState(() {});
                            if(widget.onChanged != null)
                              widget.onChanged();
                          },)
                        ])
                    );
                  }
                  ).toList(),

            ),
          ),
        ),
      ],
    );
  }
}
//
//
