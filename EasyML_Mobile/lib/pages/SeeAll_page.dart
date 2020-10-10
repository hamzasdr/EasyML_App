//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:prototyoe_project_app/blocs/model_bloc.dart';
//import 'package:prototyoe_project_app/models/conv_nn_model.dart';
//import 'package:prototyoe_project_app/models/layer_type.dart';
//import 'package:prototyoe_project_app/widgets/dialogs/create_layer_dialog.dart';
//import 'package:prototyoe_project_app/widgets/layer_item.dart';
//import 'package:provider/provider.dart';
//
//
//class See_All extends StatefulWidget {
//  ConvolutionalNeuralNetwork model;
//  See_All({this.model});
//  @override
//  _See_AllState createState() => _See_AllState();
//}
//
//class _See_AllState extends State<See_All> {
//  @override
//  Widget build(BuildContext context) {
//    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Layers'),
//      ),
//      body: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          Expanded(
//            child: Container(
////          color: Colors.red,
//              child: Padding(
//                padding: EdgeInsets.symmetric(vertical: 10),
//                child: ReorderableListView(
//                    onReorder: (int oldIndex, int newIndex){
//                      if(oldIndex == newIndex) {}
//                      else{
//                        Layer layer = widget.model.layers[oldIndex];
//                        widget.model.layers.removeAt(oldIndex);
//                        if(oldIndex < newIndex)
//                          newIndex--;
//                        widget.model.layers.insert(newIndex, layer);
//                        modelBloc.notify();
//                      }
//                    },
//                    scrollDirection: Axis.vertical,
////              itemCount: widget.model.layers.length+1
//                    children: widget.model.layers.map((Layer layer) {
////                    print(widget.model.layers.length);
//                      return Container(
//                          height: 150,
//                          key: Key("layer" + layer.id.toString()),
//                          child: Row(
//                            children: <Widget>[
//                              Stack(children: <Widget>[
//                                Text(layer.id.toString()),
//                                LayerItem(layer: layer,model: widget.model,)
//                              ]),
////                              SizedBox(width: 20,),
////                              Padding(
////                                padding: const EdgeInsets.only(left: 20,top: 10),
////                                child: Column(
////                                  children: <Widget>[
////                                    Text('Field1 : ',style: TextStyle(fontSize: 18),),
////                                    SizedBox(height: 10,),
////                                    Text('Field2 : ',style: TextStyle(fontSize: 18),),
////                                    SizedBox(height: 10,),
////                                    Text('Field3 : ',style: TextStyle(fontSize: 18),),
////                                  ],
////                                ),
////                              ),
////                              SizedBox(
////                                width: 40,
////                              ),
////                              Padding(
////                                padding: const EdgeInsets.only(left: 20,top: 10),
////                                child: Column(
////                                  children: <Widget>[
////                                    Text('Field1 : ',style: TextStyle(fontSize: 18),),
////                                    SizedBox(height: 10,),
////                                    Text('Field2 : ',style: TextStyle(fontSize: 18),),
////                                    SizedBox(height: 10,),
////                                    Text('Field3 : ',style: TextStyle(fontSize: 18),),
////                                  ],
////                                ),
////                              ),
//
//                            ],
//                          )
//                      );
//                    }
//                    ).toList(),
//
//                    header: Align(
//                      alignment: Alignment.centerLeft,
//                      child: GestureDetector(
//                        onTap: () {
//                          print('nice day');
//
//                          showDialog(context: context,
//                              builder: (BuildContext context){
//                                return CreateLayerDialog(
//                                    model: widget.model,
//                                    onCreate: () {}
//                                );
//                              });
//                        },
//                        child: Padding(
//                          padding: EdgeInsets.only(left: 7.5, right: 7.5, bottom: 10),
//                          child: Container(
//                            height: 75,
////                            width: 120,
//                            decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(30),
//                                color: Theme.of(context).primaryColor),
//                            child: Stack(
//                              children: <Widget>[
//                                ClipRRect(
//                                  borderRadius: BorderRadius.circular(30),
//                                  child: Center(
//                                    child: Icon(
//                                        Icons.add_circle,
//                                        size: 60,
//                                        color: Theme.of(context).accentColor
//                                    ),
//                                  ),
//                                  clipBehavior: Clip.antiAlias,
//                                ),
//                                Padding(
//                                  padding: EdgeInsets.all(15),
////                    child: Column(
////                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                      crossAxisAlignment: CrossAxisAlignment.center,
////                      children: <Widget>[
////                        Text(widget.modelType.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
////                        Text(widget.modelType.shortDescription, textAlign: TextAlign.center)
////                      ],
////                    ),
//                                ),
//
//                              ],
//                            ),
//                          ),
//                        ),
//                      ),
//                    )
//
//                ),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//}
