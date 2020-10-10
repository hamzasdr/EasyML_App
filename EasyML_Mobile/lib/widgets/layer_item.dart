import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/layer_type.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/dialogs/yes_no_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:provider/provider.dart';

class LayerItem extends StatefulWidget {
  MultilayerPerceptronModel model;
//  int nodes;
  int index;
  Function onChanged;
//  ModelType modelType;

  LayerItem({this.model,this.index, this.onChanged});

  @override
  _LayerItemState createState() => _LayerItemState();
}

class _LayerItemState extends State<LayerItem> {
  get child => null;
  TextEditingController _controller = TextEditingController();
  List <String> choices = ["rename","delete"];

  TextStyle teststyle = TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.hiddenLayerSizes[widget.index].toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 7.5),
      child: Container(
        width: 100,
        height: 100,
//                color: Colors.white,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
      color: Colors.white
        ),
        child: Stack(
          children: <Widget>[
            Hero(
              tag: "layer${widget.model.name}${widget.index}",
              child: SizedBox(),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // SizedBox(height: 5,),

                  TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                    controller: _controller,

                    decoration: InputDecoration(
                      isDense: true,
                      labelText: "  Layer ${widget.index+1}",
                      labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                      floatingLabelBehavior: FloatingLabelBehavior.always
                    ),
                    onSubmitted: (String value){
                      int layerCount = max(int.tryParse(value) ?? 1, 1);
                      widget.model.hiddenLayerSizes[widget.index] = layerCount;
                      if(widget.onChanged != null)
                        widget.onChanged();
                    },
                  ),

                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(Icons.content_copy),
                        onTap: (){
                          setState(() {
                            int value = widget.model.hiddenLayerSizes[widget.index];
                            widget.model.hiddenLayerSizes.insert(widget.index, value);
                          });
                          if(widget.onChanged != null)
                            widget.onChanged();
                        },
                      ),
                      GestureDetector(
                          child: Icon(Icons.delete),
                        onTap: (){
                            if(widget.model.hiddenLayerSizes.length == 1){
                              Navigator.push(context, new HeroDialogRoute(
                                builder: (BuildContext context){
                                  return InformationDialog(
                                    tag: "layer${widget.model.name}${widget.index}",
                                    text: 'You cannot have an empty list of hidden layers',
                                  );
                                }
                              ));
                              return;
                            }
                            setState(() {
                              widget.model.hiddenLayerSizes.removeAt(widget.index);
                            });
                            if(widget.onChanged != null)
                              widget.onChanged();
                        },
                      )
                    ],
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
            ),
            Padding(
              padding: EdgeInsets.all(15),
//                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      children: <Widget>[
//                        Text(widget.modelType.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
//                        Text(widget.modelType.shortDescription, textAlign: TextAlign.center)
//                      ],
//                    ),
            )
          ],
        ),
      ),
    );
  }
}
